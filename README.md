Ready for fullStack example of ForgeRocks Identity Stack Dockerized

https://github.com/kimdane/identity-stack-dockerized.git

docker run -d --link opendj --name openam-svc-a -v /var/lib/id-stack/repo:/opt/repo kimdane/openam-nightly

or stand-alone

docker run -d --link opendj --name openam-svc-a kimdane/openam-nightly

