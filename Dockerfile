FROM bitnami/minideb:jessie
RUN install_packages apt-transport-https curl gnupg2 ca-certificates
RUN install_packages bash jq curl wget telnet vim zip unzip \
            tree dnsutils tcpdump less groff unzip zip postgresql-client \
            libedit2 python-pip python-setuptools

RUN pip install awscli

RUN export KUBECTL_VERSION="v1.10.9"; \
			curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /tmp/kubectl && \
			echo "c899c110b71121f907c05da72e5d3ed33397d28648f35e895d452ffd98cf35bf  /tmp/kubectl" | sha256sum -c - && \
			cp /tmp/kubectl /usr/bin && chmod +x /usr/bin/kubectl

RUN export TERRAFORM_VERSION="0.11.8"; \
			curl -sSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip && \
			echo "84ccfb8e13b5fce63051294f787885b76a1fedef6bdbecf51c5e586c9e20c9b7  /tmp/terraform.zip" | sha256sum -c - && \
			unzip /tmp/terraform.zip -d /usr/bin
RUN curl https://raw.githubusercontent.com/bsycorp/terraform-provider-shell/master/local.sh | bash
			
RUN export KOPS_VERSION="1.10.0"; \
			curl -sSL https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 -o /tmp/kops && \
			echo "ccc64c44daa9ee6d4a63bc27f42135983527a37b98edca953488444a46797d9f  /tmp/kops" | sha256sum -c - && \
			cp /tmp/kops /usr/bin && chmod +x /usr/bin/kops && ln -s /usr/bin/kops /usr/local/bin/kops
			
RUN curl -sSL https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/Xenial/cloudhsm-client_latest_amd64.deb -o /tmp/cloudhsm.deb && \
			install_packages libjson-c2 && dpkg -i /tmp/cloudhsm.deb && \
		    touch /opt/cloudhsm/etc/customerCA.crt && \
		    chmod -R 777 /opt/cloudhsm/etc && \
		    rm /tmp/cloudhsm.deb