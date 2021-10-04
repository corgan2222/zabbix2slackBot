# Welcome to zabbix2slackBot 👋

> advanced SlackBot Script for Zabbix 

## Features:

- Zabbix Graph History
- direct Links to: Ack, Manage, Items, Trigger, History
- support for your own Icons
- compare before and after trigger values
- Kutt URL Shortner support
- debugging option

# Install

go into your alterscript folder on your zabbix server

```sh
#edit /etc/zabbix/zabbix_server.conf and add AlertScriptsPath=/usr/lib/zabbix/alertscripts
#restart zabbix server
service zabbix-server restart


cd /usr/lib/zabbix/alertscripts/
git clone https://github.com/corgan2222/zabbix2slackBot.git
cd zabbix2slackbot

#create config copy
cp slackbot.config.sample.sh slackbot.config.sh

#edit slackbot.config.sh
#change all values to fit your config
```

## Zabbix Server:

1. create Media type:

![grafik](https://user-images.githubusercontent.com/12233951/135848410-f221fd5e-85b4-4fbb-ace5-459f031bcbc5.png)

- scriptname: zabbix2slackBot/zabbix2slackBot.sh
- {ALERT.SENDTO}
- {ALERT.SUBJECT}
- {ALERT.MESSAGE}

### Message Templates:

![grafik](https://user-images.githubusercontent.com/12233951/135848669-b153acfc-40fb-4af5-ad38-a79423e447c4.png)

Problem	

``` Problem started at {EVENT.TIME} on {EVENT.DATE} Problem name: {EVENT.NAME} Host: {HOST.NAME} Severity: {EVENT.SEVERITY} Operational data: {EVENT.OPDATA} Original problem ID: {EVENT.ID} {TRIGGER.URL} ```	


Problem recovery

```Problem has been resolved at {EVENT.RECOVERY.TIME} on {EVENT.RECOVERY.DATE} Problem name: {EVENT.RECOVERY.NAME} Host: {HOST.NAME} Severity: {EVENT.SEVERITY} Original problem ID: {EVENT.ID} {TRIGGER.URL}```	


Problem update

```{USER.FULLNAME} {EVENT.UPDATE.ACTION} problem at {EVENT.UPDATE.DATE} {EVENT.UPDATE.TIME}. {EVENT.UPDATE.MESSAGE} Current problem status is {EVENT.STATUS}, acknowledged: {EVENT.ACK.STATUS}.```	


Discovery

```Discovery rule: {DISCOVERY.RULE.NAME} Device IP: {DISCOVERY.DEVICE.IPADDRESS} Device DNS: {DISCOVERY.DEVICE.DNS} Device status: {DISCOVERY.DEVICE.STATUS} Device uptime: {DISCOVERY.DEVICE.UPTIME} Device service name: {DISCOVERY.SERVICE.NAME} Device service port: {DISCOVERY.SERVICE.PORT} Device service status: {DISCOVERY.SERVICE.STATUS} Device service uptime: {DISCOVERY.SERVICE.UPTIME}```	


Autoregistration

```Host name: {HOST.HOST} Host IP: {HOST.IP} Agent port: {HOST.PORT}```



## Configuration -> Actions

### create a new actions


![grafik](https://user-images.githubusercontent.com/12233951/135849193-d9c6b54f-f03a-4ed8-aa69-7cbe5fa64057.png)
![grafik](https://user-images.githubusercontent.com/12233951/135849239-05e41233-593b-41a1-99a3-0195955b43a0.png)
![grafik](https://user-images.githubusercontent.com/12233951/135849410-01fe204c-b826-4237-86de-dc7a4584c442.png)


Operations

Subject: 

```{EVENT.NAME} {TRIGGER.STATUS}```

Message: 
```sh
HOST|{HOST.NAME}  
TRIGGER_NAME|{TRIGGER.NAME}
TRIGGER_STATUS|{TRIGGER.STATUS}
TRIGGER_SEVERITY|{TRIGGER.SEVERITY}
DATETIME|{DATE} / {TIME}
ITEM_ID|{ITEM.ID1}
ITEM_NAME|{ITEM.NAME1}
ITEM_KEY|{ITEM.KEY1}
ITEM_VALUE|{ITEM.VALUE1}
EVENT_ID|{EVENT.ID}
TRIGGER_URL|{TRIGGER.URL}
PROBLEM_STARTET|{EVENT.TIME} {EVENT.DATE}
TAG|{INVENTORY.TAG}
TYPE|{INVENTORY.TYPE}
LAST_VALUE|{ITEM.LASTVALUE1} 
VALUE|{ITEM.NAME1} ({HOST.NAME1}): {ITEM.VALUE1}
URL_A|{INVENTORY.URL.A} 
URL_B|{INVENTORY.URL.B}
SITE_A|{INVENTORY.SITE.ADDRESS.A}
SITE_B|{INVENTORY.SITE.ADDRESS.B}
LAST_VALUE_OLD|{{HOSTNAME}:{TRIGGER.KEY}.last(0)}
LAST_MIN|{{HOST.HOST}:{ITEM.KEY}.min(900)}
LAST_MAX|{{HOST.HOST}:{ITEM.KEY}.max(900)}
TRIGGER_ID|{TRIGGER.ID}
```

Recovery operations Subject: 
```
Resolved: {EVENT.NAME} {TRIGGER.STATUS}
```

Recovery operations Message : same as above

Update operations Subject: 
```
Updated problem: {EVENT.NAME}
```

Update operations Message: same as above


## Author

👤 **Stefan Knaak**

* Website: www.knaak.org
* Github: [@corgan2222](https://github.com/corgan2222)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!

Feel free to check [issues page](https://github.com/corgan2222/zabbix2slackBot/issues). 

