#!/bin/bash

set -e

HADOOP_VERSION=3.3.6
HADOOP_HOME=/usr/local/hadoop
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
HADOOP_USER=$USER

echo "=== Updating system ==="
sudo apt update -y

echo "=== Installing Java & SSH ==="
sudo apt install -y openjdk-8-jdk ssh rsync

echo "=== Setting up SSH ==="
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

echo "=== Downloading Hadoop ==="
wget -q https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
tar -xzf hadoop-$HADOOP_VERSION.tar.gz
sudo mv hadoop-$HADOOP_VERSION /usr/local/hadoop
sudo chown -R $HADOOP_USER:$HADOOP_USER /usr/local/hadoop

echo "=== Setting Environment Variables ==="
cat <<EOF >> ~/.bashrc

# Hadoop Environment Variables
export JAVA_HOME=$JAVA_HOME
export HADOOP_HOME=$HADOOP_HOME
export HADOOP_INSTALL=\$HADOOP_HOME
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_COMMON_HOME=\$HADOOP_HOME
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export YARN_HOME=\$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=\$HADOOP_HOME/lib/native"
EOF

source ~/.bashrc

echo "=== Setting JAVA_HOME in hadoop-env.sh ==="
sed -i "s|^# export JAVA_HOME.*|export JAVA_HOME=$JAVA_HOME|" $HADOOP_HOME/etc/hadoop/hadoop-env.sh

echo "=== Creating HDFS directories ==="
mkdir -p ~/hadoopdata/hdfs/{namenode,datanode}

echo "=== core-site.xml ==="
cat <<EOF > $HADOOP_HOME/etc/hadoop/core-site.xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
EOF

echo "=== hdfs-site.xml ==="
cat <<EOF > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:/home/$HADOOP_USER/hadoopdata/hdfs/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:/home/$HADOOP_USER/hadoopdata/hdfs/datanode</value>
  </property>
</configuration>
EOF

echo "=== mapred-site.xml ==="
cat <<EOF > $HADOOP_HOME/etc/hadoop/mapred-site.xml
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
</configuration>
EOF

echo "=== yarn-site.xml ==="
cat <<EOF > $HADOOP_HOME/etc/hadoop/yarn-site.xml
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>
EOF

echo "=== Formatting HDFS ==="
hdfs namenode -format -force

echo "=== Starting Hadoop Services ==="
start-dfs.sh
start-yarn.sh

echo "=== Hadoop Setup Completed ==="
echo "Run 'jps' to verify services"
