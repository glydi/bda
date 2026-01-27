# ===============================
# Hadoop Single-Node Setup Script
# Windows 10/11 – Hadoop 3.3.6
# Run PowerShell as Administrator
# ===============================

Write-Host "=== Hadoop Installation Started ==="

# -------- VARIABLES --------
$HADOOP_VERSION = "3.3.6"
$HADOOP_URL = "https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz"
$WINUTILS_URL = "https://github.com/cdarlint/winutils/raw/master/hadoop-3.3.6/bin/winutils.exe"

$BASE_DIR = "C:\Hadoop"
$HADOOP_HOME = "$BASE_DIR\hadoop"
$TMP_DIR = "C:\tmp\hadoop"

# -------- INSTALL JAVA --------
Write-Host "Installing Java..."
winget install EclipseAdoptium.Temurin8.JDK --silent

# -------- SET JAVA_HOME --------
$JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-8"
setx JAVA_HOME "$JAVA_HOME" /M
setx PATH "%PATH%;$JAVA_HOME\bin" /M

# -------- DOWNLOAD HADOOP --------
Write-Host "Downloading Hadoop..."
mkdir $BASE_DIR -Force
cd $BASE_DIR
Invoke-WebRequest $HADOOP_URL -OutFile hadoop.tar.gz
tar -xvzf hadoop.tar.gz
Rename-Item "hadoop-$HADOOP_VERSION" "hadoop"

# -------- SET HADOOP_HOME --------
setx HADOOP_HOME "$HADOOP_HOME" /M
setx PATH "%PATH%;$HADOOP_HOME\bin;$HADOOP_HOME\sbin" /M

# -------- WINUTILS --------
Write-Host "Setting up winutils..."
Invoke-WebRequest $WINUTILS_URL -OutFile "$HADOOP_HOME\bin\winutils.exe"

mkdir $TMP_DIR -Force
& "$HADOOP_HOME\bin\winutils.exe" chmod 777 C:\tmp\hadoop

# -------- HADOOP CONFIG --------
$CONF_DIR = "$HADOOP_HOME\etc\hadoop"

# core-site.xml
@"
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
  </property>
</configuration>
"@ | Set-Content "$CONF_DIR\core-site.xml"

# hdfs-site.xml
@"
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file:///C:/Hadoop/data/namenode</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:///C:/Hadoop/data/datanode</value>
  </property>
</configuration>
"@ | Set-Content "$CONF_DIR\hdfs-site.xml"

# mapred-site.xml
@"
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
</configuration>
"@ | Set-Content "$CONF_DIR\mapred-site.xml"

# yarn-site.xml
@"
<configuration>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
</configuration>
"@ | Set-Content "$CONF_DIR\yarn-site.xml"

# -------- DATA DIRS --------
mkdir C:\Hadoop\data\namenode -Force
mkdir C:\Hadoop\data\datanode -Force

# -------- FORMAT NAMENODE --------
Write-Host "Formatting NameNode..."
& "$HADOOP_HOME\bin\hdfs.cmd" namenode -format

# -------- START SERVICES --------
Write-Host "Starting Hadoop services..."
& "$HADOOP_HOME\sbin\start-dfs.cmd"
& "$HADOOP_HOME\sbin\start-yarn.cmd"

# -------- VERIFY --------
Write-Host "Running JPS..."
jps

Write-Host "=== Hadoop Setup Complete ==="
Write-Host "HDFS UI  : http://localhost:9870"
Write-Host "YARN UI  : http://localhost:8088"
