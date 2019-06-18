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
COPY --from=0 /usr/bin/docker-credential-ecr-login /usr/bin/docker-credential-ecr-login
RUN install_packages apt-transport-https curl gnupg2 ca-certificates software-properties-common
RUN install_packages bash jq wget telnet vim zip unzip \
            tree dnsutils tcpdump less groff unzip zip postgresql-client \
            libedit2 python-pip python-setuptools lsb-release 
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
            install_packages docker-ce=18.06.2~ce~3-0~debian
RUN pip install 'awscli==1.16.59'

RUN export KUBECTL_VERSION="v1.11.6"; \
			curl -sSL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /tmp/kubectl && \
			echo "92c2abb450af253e4a61bef56787a765e921fbc25d5e6343cf33946033b62976  /tmp/kubectl" | sha256sum -c - && \
			cp /tmp/kubectl /usr/bin && chmod +x /usr/bin/kubectl

RUN curl -sSL https://github.com/tfutils/tfenv/releases/download/v1.0.0/tfenv-v1.0.0.zip -o /tmp/tfenv.zip && \
    echo "5d4d84d0acf04b64dfe3067fcd8e9cfc2918cba530040815ded1454ecdff617b /tmp/tfenv.zip" | sha256sum -c - && \
    unzip /tmp/tfenv.zip -d /usr/local
# The validation done by tfenv is not so great, so we just do it ourselves.
RUN tfenv install 0.12.1 && \
    tfenv install 0.12.2 && \
    tfenv install 0.11.10 && \
    echo "784af019360c38942b07d48678a8c633de4fb91bcf51925478bda9611d7b9001  /usr/local/versions/0.12.2/terraform" | sha256sum -c - && \
    echo "b042ceb96b60d6f12b2b72fe91b813dc89e590f5d277e9815692485904decc25  /usr/local/versions/0.12.1/terraform" | sha256sum -c - && \
    echo "1a2862811f51effc9c782c47b1b08b9e6401b953b973dc6f734776df01df2618  /usr/local/versions/0.11.10/terraform" | sha256sum -c -

RUN export KOPS_VERSION="1.11.0"; \
			curl -sSL https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 -o /tmp/kops && \
			echo "3804b9975955c0f0a903ab0a81cf80459ad00375a42c08f2c959d81c5b246fe2  /tmp/kops" | sha256sum -c - && \
			cp /tmp/kops /usr/bin && chmod +x /usr/bin/kops && ln -s /usr/bin/kops /usr/local/bin/kops

COPY start-docker /usr/bin/start-docker
COPY codebuild-creds /usr/bin/codebuild-creds
