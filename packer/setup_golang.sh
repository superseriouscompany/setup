curl -O https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz
tar xzvf go1.7.4.linux-amd64.tar.gz
sudo chown -R root:root ./go
sudo mv go /usr/local
mkdir ~/go
echo "export GOPATH=\$HOME/go" >> ~/.profile
echo "export PATH=\$PATH:/usr/local/go/bin:$GOPATH/bin" >> ~/.profile
