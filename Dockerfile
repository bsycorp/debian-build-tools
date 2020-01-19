FROM bitnami/minideb:stretch
RUN install_packages curl ca-certificates bash jq wget telnet vim zip unzip \
            tree dnsutils moreutils tcpdump less groff unzip zip postgresql-client \
            libedit2 python3-pip python3-setuptools lsb-release git
RUN curl -sSL https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.4.0/linux-amd64/docker-credential-ecr-login -o /tmp/docker-credential-ecr-login && \
    echo "2c8fc418fe1b5195388608c1cfb99ba008645f3f1beb312772c9490c39aa5904 /tmp/docker-credential-ecr-login" | sha256sum -c - && \
    cp -f /tmp/docker-credential-ecr-login /usr/bin/docker-credential-ecr-login && \
    chmod +x /usr/bin/docker-credential-ecr-login
RUN pip3 install awscli
# docker:stable 18.06
COPY --from=docker@sha256:d0ae46aa08806ffc1c4de70a4eb585df33470643a9d2ccf055ff3ec91ba5b0b0 /usr/local/bin/docker /usr/bin/docker
# kubectl 1.11.6
COPY --from=bitnami/kubectl@sha256:92e9b698b80a298ac355c74f0bbb0318b994fcf42855fd7010f5088043b396da /opt/bitnami/kubectl/bin/kubectl /usr/bin/kubectl
# KOPS 1.11.0
COPY --from=aztek/kops@sha256:67fd070812756b9beb7d4f5746fd9c8e287e9c5665819ecd587afbc3c8b52a2e /usr/local/bin/kops /usr/bin/kops-1.11.0
# KOPS 1.12.2
COPY --from=aztek/kops@sha256:832b4fca5d8c548d6ec6f2a6cc3100bb236122926a2cd0d58aa8e9779d7ccd7d /usr/local/bin/kops /usr/bin/kops-1.12.2
# KOPS 1.15.0
COPY --from=aztek/kops@sha256:0e80884988938e8ef3f06c002ad9251a119011a5abd84564a3550ac37ea94248 /usr/local/bin/kops /usr/bin/kops-1.15.0
RUN ln -s /usr/bin/kops-1.11.0 /usr/bin/kops && \
    ln -s /usr/bin/kops-1.11.0 /usr/local/bin/kops
    
RUN curl -sSL https://github.com/warrensbox/terraform-switcher/releases/download/0.7.737/terraform-switcher_0.7.737_linux_amd64.tar.gz -o /tmp/tfswitch.tar.gz && \
    echo "74ddef90336aad8a54bca94072f71e011695cc17e2e2445e369e801c938cfb08 /tmp/tfswitch.tar.gz" | sha256sum -c - && \
    tar -xf /tmp/tfswitch.tar.gz -C /usr/local/bin && \
    rm -f /tmp/tfswitch.tar.gz && \
    tfswitch 0.11.10 && \
    tfswitch 0.12.2

COPY start-docker /usr/bin/start-docker
COPY codebuild-creds /usr/bin/codebuild-creds
