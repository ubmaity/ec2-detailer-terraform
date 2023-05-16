from flask import Flask, jsonify
from apscheduler.schedulers.background import BackgroundScheduler
import requests
import smtplib
from email.mime.text import MIMEText


app = Flask(__name__)
scheduler = BackgroundScheduler()


@app.route('/')
def index():
    instance_id = requests.get('http://169.254.169.254/latest/meta-data/instance-id').text
    ip_address = requests.get('http://169.254.169.254/latest/meta-data/public-ipv4').text
    mac_address = requests.get('http://169.254.169.254/latest/meta-data/network/interfaces/macs').text
    return f'<html><body><h1>Instance Details of this VM are as follows:</h1><p>Instance ID: {instance_id}</p><p>IP Address: {ip_address}</p><p>MAC Address: {mac_address}</p></body></html>'


# There is also an external health endpoint which monitors the application after every 5 minutes from the cloudwatch metrics in case the whole flask application gets stopped.
# Decoupling the flask application and the external health check for more reliable feedbacks

@app.route('/health')
def health_check():
    return 'OK'

#configuring the internal health checks
def perform_health_check():
    response = requests.get('http://localhost:5000/health')
    if response.status_code != 200:
        send_email_notification('Health Check Failed', 'The health check endpoint returned an error.')

def send_email_notification(subject, message):
    # Configure Email 
    sender_email = 'xyz@example.com'
    receiver_email = 'u.b.maity@gmail.com'
    smtp_server = 'email-smtp.ap-south-1.amazonaws.com'
    smtp_port = 587
    smtp_username = 'your-username'
    smtp_password = 'your-password'

    msg = MIMEText(message)
    msg['Subject'] = subject
    msg['From'] = sender_email
    msg['To'] = receiver_email

    #sends the email here
    with smtplib.SMTP(smtp_server, smtp_port) as server:
        server.starttls()
        server.login(smtp_username, smtp_password)
        server.sendmail(sender_email, receiver_email, msg.as_string())

if __name__ == '__main__':
    # Add the health check task to the scheduler . This will check the health of the application after every 2 minutes
    scheduler.add_job(perform_health_check, 'interval', minutes=2)
    scheduler.start()

    app.run(debug=True)
