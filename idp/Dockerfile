FROM tomcat:9.0.31-jdk11-openjdk

# 必要なパッケージをインストールする
RUN apt-get update && \
    apt-get -y install expect patch && \
    apt-get -y install apache2

RUN a2enmod proxy
RUN a2enmod proxy_ajp

COPY conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf

# Tomcatの設定ファイルに当てる各種パッチをコンテナにコピーする。
COPY patch/* /tmp/

# AJP(8009ポート)で待ち受けするようserver.xmlにパッチを当てる
RUN cd /usr/local/tomcat/conf && \
    patch -b < /tmp/server.xml.patch

# Shibbolethのビルド用ファイルをコンテナにコピーする。
COPY bin/build.sh /usr/local/bin/

# shibbolethの設定ファイル生成用Dockerコンテナで生成されたファイルをコンテナにコピーする
ADD customized-shibboleth-idp /opt/shibboleth-idp

# ビルドの結果作成されたidp.warをTomcatのwebappsディレクトリにコピーする。
RUN chmod 755 /usr/local/bin/build.sh && \
    /usr/local/bin/build.sh && \
    cp /opt/shibboleth-idp/war/idp.war /usr/local/tomcat/webapps

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:Docker!' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
 
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
 
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY bin/init-run.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/init-run.sh

EXPOSE 2222 80

CMD ["/usr/local/bin/init-run.sh"]
