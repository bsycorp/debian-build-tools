FROM golang:1.10
RUN export GOPATH=/go \
    && export PATH=$GOPATH/bin:$PATH \
    && chmod -R 777 $GOPATH \
    && APP_REPO=github.com/awslabs/amazon-ecr-credential-helper \
    && git clone https://$APP_REPO $GOPATH/src/$APP_REPO \
    && cd $GOPATH/src/$APP_REPO \
    && GOOS=linux CGO_ENABLED=0 go build -installsuffix cgo \
       -a -ldflags '-s -w' -o /usr/bin/docker-credential-ecr-login \
       ./ecr-login/cli/docker-credential-ecr-login 

FROM bitnami/minideb:stretch
COPY --from=0 /usr/bin/docker-credential-ecr-login /usr/bin/docker-credential-secretservice
RUN install_packages apt-transport-https curl gnupg2 ca-certificates software-properties-common
RUN install_packages bash jq wget telnet vim zip unzip \
            tree dnsutils tcpdump less groff unzip zip postgresql-client \
            libedit2 python-pip python-setuptools lsb-release
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
            install_packages docker-ce
RUN pip install 'awscli==1.16.59'

RUN export KUBECTL_VERSION="v1.11.6"; \
			curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /tmp/kubectl && \
			echo "92c2abb450af253e4a61bef56787a765e921fbc25d5e6343cf33946033b62976  /tmp/kubectl" | sha256sum -c - && \
			cp /tmp/kubectl /usr/bin && chmod +x /usr/bin/kubectl

RUN export TERRAFORM_VERSION="0.11.10"; \
			curl -sSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip && \
			echo "43543a0e56e31b0952ea3623521917e060f2718ab06fe2b2d506cfaa14d54527  /tmp/terraform.zip" | sha256sum -c - && \
			unzip /tmp/terraform.zip -d /usr/bin
RUN curl https://raw.githubusercontent.com/bsycorp/terraform-provider-shell/master/local.sh | bash
			
RUN export KOPS_VERSION="1.11.0"; \
			curl -sSL https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 -o /tmp/kops && \
			echo "3804b9975955c0f0a903ab0a81cf80459ad00375a42c08f2c959d81c5b246fe2  /tmp/kops" | sha256sum -c - && \
			cp /tmp/kops /usr/bin && chmod +x /usr/bin/kops && ln -s /usr/bin/kops /usr/local/bin/kops

COPY start-docker /usr/bin/start-docker
