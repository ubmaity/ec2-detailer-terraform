from flask import Flask
import requests

app = Flask(__name__)

@app.route('/')
def index():
    instance_id = requests.get('http://169.254.169.254/latest/meta-data/instance-id').text
    ip_address = requests.get('http://169.254.169.254/latest/meta-data/public-ipv4').text
    mac_address = requests.get('http://169.254.169.254/latest/meta-data/network/interfaces/macs').text
    return f'<html><body><h1>Instance Details in Cloud Systems:</h1><p>Instance ID: {instance_id}</p><p>IP Address: {ip_address}</p><p>MAC Address: {mac_address}</p></body></html>'

@app.route('/health')
def health_check():
    return 'OK'

if __name__ == '__main__':
    app.run(debug=True)