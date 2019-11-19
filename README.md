# computate-solr
```bash
sudo mkdir /usr/local/src/computate-solr
sudo chown $USER: /usr/local/src/computate-solr/
git clone git@github.com:computate/computate-solr.git /usr/local/src/computate-solr/
cd /usr/local/src/computate-solr
docker build -t computate/computate-solr:latest .
docker login
docker push computate/computate-solr:latest
git add -i
git commit
git push
oc replace --force -f "https://raw.githubusercontent.com/computate/computate-solr/master/openshift-computate-solr.json"
```
