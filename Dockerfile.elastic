FROM elasticsearch:7.4.2
RUN echo "elasticsearch soft memlock unlimited" >> /etc/security/limits.conf && echo "elasticsearch hard memlock unlimited" >> /etc/security/limits.conf
RUN bin/elasticsearch-plugin install --batch repository-s3 && bin/elasticsearch-plugin install --batch discovery-ec2 && bin/elasticsearch-plugin install --batch analysis-icu
