#!/bin/bash
set -ex



# Install
test -n "$GPHOME" || test -n "OUSHUDB_HOME"
if [[ $GPHOME =~ 6.0 ]]; then
  path="$(cd "$(dirname "${BASH_SOURCE[0]-$0}")" && pwd)"
  $path/init_oushudb6.sh
  exit
fi
if [[ -n $OUSHUDB_HOME ]]; then
  export GPHOME=$OUSHUDB_HOME
  mkdir -p /usr/local/oushu/conf/oushudb
  mkdir -p /usr/local/oushu/log/oushudb/admin/
  cp -a $GPHOME/conf.empty/* /usr/local/oushu/conf/oushudb/
  ln -snf /usr/local/oushu/conf/oushudb /usr/local/oushu/oushudb/etc
  ln -snf oushudb-site.xml /usr/local/oushu/oushudb/etc/hawq-site.xml
  ln -snf oushudb /usr/local/oushu/oushudb/bin/hawq
fi

# Configure
tee $GPHOME/etc/hawq-site.xml << EOF
<configuration>
    <property>
        <name>hawq_dfs_url</name>
        <value>localhost:8020/hawq_default</value>
        <description>URL for accessing HDFS.</description>
    </property>
    <property>
        <name>hawq_master_address_host</name>
        <value>localhost</value>
    </property>
    <property>
        <name>hawq_master_address_port</name>
        <value>5432</value>
    </property>
    <property>
        <name>hawq_segment_address_port</name>
        <value>40000</value>
    </property>
    <property>
        <name>hawq_master_directory</name>
        <value>${HOME}/db_data/hawq-data-directory/masterdd</value>
    </property>
    <property>
        <name>hawq_segment_directory</name>
        <value>${HOME}/db_data/hawq-data-directory/segmentdd</value>
    </property>
    <property>
        <name>hawq_master_temp_directory</name>
        <value>/tmp</value>
    </property>
    <property>
        <name>hawq_segment_temp_directory</name>
        <value>/tmp</value>
    </property>
    <property>
        <name>hawq_magma_port_master</name>
        <value>50000</value>
    </property>
    <property>
        <name>hawq_magma_port_segment</name>
        <value>50005</value>
    </property>
    <property>
        <name>hawq_magma_locations_master</name>
        <value>file://${HOME}/db_data/hawq-data-directory/magma_master</value>
    </property>
    <property>
        <name>hawq_magma_locations_segment</name>
        <value>file://${HOME}/db_data/hawq-data-directory/magma_segment</value>
    </property>
    <property>
        <name>hawq_init_with_hdfs</name>
        <value>true</value>
        <description>choose whether initing hawq cluster with hdfs</description>
    </property>
    <property>
        <name>default_table_format</name>
        <value>appendonly</value>
        <description>default table format when creating table </description>
    </property>
        <property>
                <name>default_hash_table_bucket_number</name>
                <value>4</value>
        </property>

        <property>
                <name>max_jump_hash_map_num</name>
                <value>16</value>
        </property>
        <property>
                <name>catalog_url</name>
                <value>default_nameservice/vsc_catalog</value>
        </property>
        <property>
                <name>magma_dfs_url</name>
                <value>default_nameservice/vsc_default</value>
        </property>
</configuration>
EOF

# Initialize
# rm -rf /opt/dependency*
rm -rf ${HOME}/db_data/hawq-data-directory
install -d ${HOME}/db_data/hawq-data-directory/masterdd
install -d ${HOME}/db_data/hawq-data-directory/segmentdd
install -d ${HOME}/db_data/hawq-data-directory/magma_master
install -d ${HOME}/db_data/hawq-data-directory/magma_segment

export PGDATABASE=postgres
version=$(hawq version | sed -E 's/.*version (.*)/\1/')
major_version=$(cut -d. -f1 <<<$version)
minor_version=$(cut -d. -f2 <<<$version)

if [[ $major_version -ge 5 ]]; then
  cd /usr/local/oushu/conf/oushudb/

  master_host=$(hostname)

  tee oushudb-topology.yaml <<config_EOF
nodes:
 - id: m1
   addr: ${master_host}
   label: { region: "regionA", zone: "zoneA"}

vc:
 - name: mains
   vci:
    - nodes: m1
 - name: vc_default
   hash_table_bucket_number: 4
   magma_hash_table_nvseg_perseg: 4
   max_nvseg_perquery_perseg: 4
   vci:
    - name: vci1
      nodes: m1
config_EOF

tee magma-topology.yaml <<magma_topology_EOF
nodes:
 - id: m1
   addr: ${master_host}
   label: { region: "regionA", zone: "zoneA"}

vsc:
 - name: vsc_catalog
   nodes: m1
   port: 6666
   num_ranges: 1
   num_replicas: 1
   data_dir: ${HOME}/db_data/hawq-data-directory/magma_master
   replica_locations: "regionA.zoneA:1"
   leader_preferences: "regionA.zoneA"

 - name: vsc_default
   nodes: m1
   port: 6676
   num_ranges: 4
   num_replicas: 1
   data_dir: ${HOME}/db_data/hawq-data-directory/magma_segment
   replica_locations: "regionA.zoneA:1"
   leader_preferences: "regionA.zoneA"
magma_topology_EOF

  sed -i "s/localhost/$master_host/g" magma-client.xml

  oushudb init cluster -a --with_magma
else
  hawq init cluster -a
fi

if [[ $major_version -ge 5 || $major_version -ge 4 && $minor_version -ge 4 ]]; then
  psql -c "ALTER RESOURCE QUEUE vc_default.pg_default with (VSEG_RESOURCE_QUOTA='mem:256MB');"
else
  psql -c "ALTER RESOURCE QUEUE pg_default with (VSEG_RESOURCE_QUOTA='mem:256MB');"
fi
