# Hands-on Jenkins-05 : Install & Configure Tomcat on Amazon Linux 2 AWS EC2 Instances

Purpose of the this hands-on training is to install & configure Tomcat server for staging and prodcution environment.

## Learning Outcomes

At the end of the this hands-on training, students will be able to;

- install and configure Tomcat server.


## Outline

- Part 1 - Launch 2 ec-2 free tier instances and Connect with SSH

- Part 2 - Install Java JDK

- Part 3 - Install Tomcat

- Part 4 - Configure Tomcat

- Part 5 - Auto start of tomcat server at boot

## Part 1 - Launch 2 ec2 free tier instances and Connect with SSH

- The security group must allow  SSH (port 22) and HTTP (8080)

- connect to ec2 free tier instances 
  
```bash
ssh -i .ssh/mykey.pem ec2-user@ec2-3-133-106-98.us-east-2.compute.amazonaws.com
```

## Part 2 - Install Java JDK

- Install Java

- For Centos & Fedora (Amazon ec-2 instance)
```bash
sudo yum install java-1.8.0-openjdk -y
```

## Part 3 - Install Tomcat


- For Centos & Fedora (Amazon ec-2 instance)
  
```bash
sudo yum install unzip wget -y
```

- Install Tomcat

- Got to https://tomcat.apache.org/download-80.cgi page  #sayfaya git zip link kopyala sonra wget ile 73.satirdaki gibi uygula

- Look at Binary Distributions and copy the link of the `zip`ed one.

```bash
...
Core:
zip (pgp, sha512) [select this for linux, thus copy the link]
tar.gz (pgp, sha512)
32-bit Windows zip (pgp, sha512)
64-bit Windows zip (pgp, sha512)
32-bit/64-bit Windows Service Installer (pgp, sha512)
...
```

-  Get the tomcat file
  
```bash
cd /tmp
wget https://ftp.itu.edu.tr/Mirror/Apache/tomcat/tomcat-8/v8.5.71/bin/apache-tomcat-8.5.71.zip
```

- Unzip tomcat file and move to `/opt`
  
```bash
unzip apache-tomcat-*.zip
sudo mv apache-tomcat-8.5.71 /opt/tomcat
```

## Part 4 - Configure tomcat

- Now Change Tomcat Server Port
cd /opt
ls
cd tomcat/
ls
cd /opt/tomcat # (yukardaki komutlar bunun acilimi)
cd conf  # ile configure dosyasinin icine giriyoruz
ls # ile icine bakiyoruz ve server.xml goruruz)
sudo cat server.xml  # icine bakiyoruz asagida ki connector varligini ve dogrulugunu teyit ettik)
- Go to 'cat /opt/tomcat/conf/server.xml' file
- Search for `Connector` and verify/change the Port Value, save the file.

```bash
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
```

- Change Permission of Scripts in `/opt/tomcat/bin`
Not: onemli
cd ..           # ile conf klasorunden ciktik tomcat geldik
ls              # tomcat icinde binary(bin) var ve bunun icine girelim
cd bin 
ls          # altinda ki dosyalar tomcat ile ilgili bir suru islem var(orn:startup.sh, shutdown vs ihtiyac duydugumuz binary var)
sudo chmod +x *  # bu komut ile binary klasorun altinda ki tum dosyalara yetki veriyoruz
pwd              # yaptigimizda /opt/tomcat/bin gormus oluruz
👇👇👇 asagida ki 3 komutun acilimi yukarda ki komutlardir.
```bash
cd /opt/tomcat/bin
ls -la
sudo chmod +x *  #butun dosyalar execute yapiyoruz
```

- Set Credentials of Tomcat that Jenkins will use.
cd ..    # ile tomcat klasorune geri donduk
pwd      # /opt/tomcat gorecegiz
ls       # diyecegiz ve conf gidiyoruz cunku configure etmemiz gerekiyor
cd conf  # dosyasina gidiyoruz
ls       # dedigimizde burda olan  tomcat-users.xml dosyasi ile tomcate user ve password tanimlayacagiz.

```bash
cd /opt/tomcat/conf && ls
```
- Update `vim tomcat-users.xml`/`nano tomcat-users.xml`/ 'sudo vi tomcat-users.xml' file.

- `manager-script` & `admin-gui` are needed for jenkins to access tomcat.

- Set roles as `manager-script` & `admin-gui` and set password to tomcat as follows:

```bash
  <role rolename="manager-script"/>
  <role rolename="admin-gui"/>
  <user username="tomcat" password="tomcat" roles="manager-script,admin-gui"/>
```

- Note : Don't forget to remove the xml comment bloks `<!--` and `-->`. Delete these enclosing lines.


cd .. && ls #diyoruz ve tomcat klasorune gidiyoruz 
              👇👇👇 uygula
- Go to the `cd /opt/tomcat/webapps/host-manager/META-INF/` and edit file `context.xml`. Actually commenting out the tagged `CookieProcessor` and `Valve` parts.
pwd && ls
sudo vi context.xml

```bash
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<Context antiResourceLocking="false" privileged="true" >
	<!--
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> # local host guvenlik onlemleri var.bu satir sadece local host izin veriyor. Jenkinste herseyi otomatik hale getiriyoruz ya jenkins yeni islemler yapacagiz oradan jenkinsten tomcat servere diyecegiz ki bu kodu publish et Jenkinsden bunu dememiz icin (<CookieProcessor baslayan ve allow=127 bununla biten) guvenlik kismini kaldiriyoruz
	-->
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
```

- Go to the `cd /opt/tomcat/webapps/manager/META-INF/` and edit file `context.xml`. Actually commenting out the tagged `CookieProcessor` and `Valve` parts.
sudo vi context.xml
```bash
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<Context antiResourceLocking="false" privileged="true" >
<!--
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
	sameSiteCookies="strict" />
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
-->
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
```


- Restart the tomcat server

```bash
sudo /opt/tomcat/bin/shutdown.sh  # yeni islem yaptigimiz icin bu komutlari calistiriyoruz
sudo /opt/tomcat/bin/startup.sh
```

## Part 5 - Auto start of Tomcat server at boot  # boot bilgisayar yeni ayaga kalkarken istiyoruz ki tomcat server ayaga kalksin her seferinde startup komutunu calistirmayalim

- In able to auto start Tomcat server at boot, we have to make it a `service`. Service is process that starts with operating system and runs in the background without interacting with the user.

- Service files are located in /etc/systemd/system.

- Go to /etc/systemd/system folder.

```bash
cd /etc/systemd/system #tomcat service haline getiriyoruz. arkada calisan programlara servis diyoruz.
ls
```

- In able to declare a service "unit file" must be created. Create a `tomcat.service` file.

```bash
sudo vi tomcat.service
```

- Copy and paste this code in "tomcat.service" file.
```
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

[Install]
WantedBy=multi-user.target
```

- Save and exit.

- Enable Tomcat server.

```bash
sudo systemctl enable tomcat # sistem her calistiginda yeniden baslat
```

- Start Tomcat server.

```bash
sudo systemctl start tomcat
```
sudo systemctl status tomcat

- Open your browser, get your Tomcat server ec2 instance Public IPv4 DNS and paste it at address bar with 8080. 
"http://[ec2-public-dns-name]:8080"



