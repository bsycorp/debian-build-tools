FROM bitnami/minideb:stretch
RUN install_packages apt-transport-https curl gnupg2 ca-certificates
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -; \
			mkdir -p /etc/apt/sources.list.d/ && touch /etc/apt/sources.list.d/kubernetes.list && \
			echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN install_packages bash jq curl wget telnet vim \
            tree dnsutils tcpdump less groff unzip zip postgresql-client \
            libedit2 kubectl awscli

RUN export TERRAFORM_VERSION="0.11.8"; \
			curl -sSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip && \
			echo "84ccfb8e13b5fce63051294f787885b76a1fedef6bdbecf51c5e586c9e20c9b7  /tmp/terraform.zip" | sha256sum -c -; \
			unzip /tmp/terraform.zip -d /usr/bin