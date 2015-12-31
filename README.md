Ready for fullStack example of ForgeRocks Identity Stack Dockerized

https://github.com/ConductAS/identity-stack-dockerized.git

docker run -d --link opendj --name openam-svc-a -v /var/lib/id-stack/repo:/opt/repo conductdocker/openam-nightly

or stand-alone

docker run -d --link opendj --name openam-svc-a conductdocker/openam-nightly

