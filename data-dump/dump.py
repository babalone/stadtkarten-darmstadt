# coding: utf-8
import urllib
import urllib3
#import urllib.request
import certifi
import time
from datetime import datetime

url_file = open("URLs", "r", encoding="utf8")
urls = url_file.read().splitlines()
base_url = u"https://stadtatlas.darmstadt.de"
timestamp = datetime.now()

for path in urls:
    print("-------------------------------------------------------------------------------------------")
    url = base_url + path
#    url = urllib.parse.quote(url, safe=':/')
#    url = urllib.parse.quote(url, safe=':/')
    print(f"url: {url}")
    http = urllib3.PoolManager(cert_reqs = 'CERT_REQUIRED', ca_certs = certifi.where())
    response = http.request("GET", url)
    print("status: ", response.status)
    s = response.data
    print(s)
    out_file_name = path.replace("/", "-").replace(".geojson", "." + timestamp.strftime("%Y-%m-%dT%H-%M-%S") + ".geojson").replace("-geojson-", "")
    print(f"outfile: {out_file_name}")
    out_file = open("data/" + out_file_name, "wb")
    out_file.write(s)
    print("===========================================================================================")
    print()
