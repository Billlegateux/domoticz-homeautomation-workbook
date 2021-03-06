#!/usr/bin/python3
"""
Switch an LED connected to GPIO 18 on/off by using a push-button connected to GPIO 23.
Wait till the event has run first time to setup, then press button.
If the button is pressed or relased, the text device GPIO Status is updated.
The event is running every minute - but doing nothing.
20200610 rwl
"""

import domoticz2
import DomoticzEvents as DE
import datetime
# urlib to update device(s)
import urllib.request
# parse values into the url
import urllib.parse
import RPi.GPIO as GPIO

# GPIO pin numbers
LEDPIN = 18
BUTTONPIN = 23

IDX_GPIO_STATUS = 129

"""
Write a string to the domoticz log
"""
def tolog(msg):
    domoticz2.log(msg)

"""
Get the current date & time in format "YYYYMMDD HH:MM:SS"
"""
def getnow():
    now = datetime.datetime.now()
    return now.strftime("%Y%m%d %X")

"""
Update the text of the device named "GPIO_STATUS"
"""
def updateGPIOStatus(state):
    msg = "Update GPIO Status: {}".format(state)
    tolog(msg)
    # Update GPIO Status: ON 
    data = urllib.parse.quote("LED turned {} @ {}.".format(state, getnow()))
    # LED%20turned%20ON. 
    req = "http://192.168.1.179:8080/json.htm?type=command&param=udevice&idx={}&nvalue=0&svalue={}".format(IDX_GPIO_STATUS, data)
    tolog(req)
    # http://192.168.1.179:8080/json.htm?type=command&param=udevice&idx=129&nvalue=0&svalue=LED%20turned%20OFF%20%40%2020200609%2014%3A52%3A14.
    resp = urllib.request.urlopen(req)
    respData = resp.read().decode('utf-8')
    msg = "Update GPIO Status: {}".format(respData)
    tolog(msg)
    # Update GPIO Status: b'{\n\t"status" : "OK",\n\t"title" : "Update Device"\n}\n' 
    msg = "Update GPIO Status: done"
    tolog(msg)
    return

# Define handling button pressed & released
def button_callback(channel):
    state = "UNKNOWN"
    if GPIO.input(BUTTONPIN) == GPIO.HIGH:
        GPIO.output(LEDPIN,GPIO.HIGH)
        state = "ON"
    if GPIO.input(BUTTONPIN) == GPIO.LOW:
        GPIO.output(LEDPIN,GPIO.LOW)
        state = "OFF"
    msg = "Button was pressed. LED changed: {}".format(state)
    tolog(msg)
    updateGPIOStatus(state)

def setup():
    # GPIO mode & warnings
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)
    # LED and BUTTON objects
    try:
        GPIO.setup(LEDPIN,GPIO.OUT)
        GPIO.setup(BUTTONPIN, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
        GPIO.add_event_detect(BUTTONPIN,GPIO.BOTH,callback=button_callback)
        GPIO.output(LEDPIN,GPIO.LOW)
    except:
        # do nothing
        # tolog("Setup already done")
        dummy = 1

# Event is running every minute
# Setup is only required firsttime, this is handled by try-except block in function setup
# Consider using GPIO.cleanup()
setup()
