import json
import re

import pandas as pd
import requests
from bs4 import BeautifulSoup
import pandas as pd
		




 # Part 1: Web Scraping
def getStockInformation(target: str):
	"""
	do not re-run it several times in short time because there is no ip-list in the function
	if you re-run it for many times in short time, your ip will be blocked by yahoo
	:param target: str
	:return: pd.DataFrame
	"""

	save_dict = {}
	url = "http://finance.yahoo.com/quote/{}?p={}".format(target, target)
	page = requests.get(url).text
	soup = BeautifulSoup(page, "lxml")
	# make sure find the target stock
	pattern = re.compile('Symbols similar to \'{}\''.format(target))
	result = pattern.findall(soup.decode("utf-8"))
	# if not find the target stock ,re-get the most possible stock informatione
	# according to the website
	if len(result) != 0:
		# find the most possible stock acronym
		first_find = soup.find(
			"td", {
				"class": "data-col0 Ta(start) Pstart(6px) Pend(15px)"}).find("a")
		new_target = first_find.contents[0]
		print("Can not find a suitable stock acronym for target, return the most possible stock symbol {}".format(
			new_target))
		new_url = "http://finance.yahoo.com/quote/{}?p={}".format(
			new_target, new_target)
		new_page = requests.get(new_url).text
		new_soup = BeautifulSoup(new_page, "lxml")
		tables = new_soup.findAll("table")
	else:
		tables = soup.findAll("table")
	# turn html table into dataframe and output it
	if len(tables) != 0:
		for table in tables:
			rows = table.findAll('tr')
			for row in rows:
				cols = row.findAll('td')
				need_element = [element.text.strip() for element in cols]
				save_dict[need_element[0]] = need_element[1]
		data = pd.DataFrame.from_dict(list(save_dict.items()))
		print(data)
	else:
		print("Can not find a suitable information from Yahoo")
		data = None
	return data


# Part 2: Using an API.
# test 20002, 90210, and 80302


def getDataFromAirNow(zipCode: str):
	"""
	:param zipCode: str
	:return: pd.DataFrame
	"""
	url = "https://www.airnowapi.org/aq/forecast/zipCode/?format=application/json&zipCode={}&date=2017-06-17&distance=25&API_KEY=FC747838-AB17-477A-9CC9-4066AB412A5B".format(
		zipCode)
	data_json = requests.get(url).text
	if len(data_json) != 0:
		data = pd.DataFrame(json.loads(data_json))
		print(data.__repr__())
		with open(r"../GU_bootcamp/Part2_OUTFILE.txt", "a+") as f:
			data.to_csv(r"../GU_bootcamp/Part2_OUTFILE.txt",
						sep="\t", mode="a+")
			f.write("\n\nnow the zipCode is {}".format(zipCode))
			f.write("\n")
			f.write("-----------------------------\n\n")

	else:
		print("Can not get suitable information from api")
		data = None
	return data


def stringRight(target: str, input: str):
	p = re.compile(target)
	result = p.search(input)
	if result is not None:
		return True
	else:
		return False


def userInput():
	"""
	for user to choose which way to get data
	:return:
	"""

	wrong_or_back = 0  # 0 wrong,1 back to the choose api or yahoo
	stop_count = 0  # if stop_count > 10, break , emergency stop

	while True:
		if wrong_or_back == 1:
			continue_function = input(
				"do you want to exit the whole function, yes or no")
			if stringRight(target="yes", input=str(continue_function)):
				return
			else:
				pass
		choose_way = input(
			"Please choose one of the way to get data,api or yahoo")
		if stringRight(target="api", input=str(choose_way)):
			while True:
				zipcode = input(
					"Please enter the zipcode, and the zipcode is made of 5 numbers")
				getDataFromAirNow(zipCode=zipcode)
				api_continue = input(
					"do you still want to re-enter the zipcode,yes or no")
				if stringRight(target="yes", input=str(api_continue)):
					pass
				else:
					wrong_or_back = 1
					break
		elif stringRight(target="yahoo", input=str(choose_way)):
			while True:
				choose_stamp = input(
					"Please enter stock acronym or the company name")
				getStockInformation(target=choose_stamp)
				stamp_continue = input(
					"do you still want to re-enter the stock acronym or the company name, yes or no")
				if stringRight(target="yes", input=str(stamp_continue)):
					pass
				else:
					wrong_or_back = 1
					break
		else:
			wrong_or_back = 0
			print("you choose wrong way to get data")
			stop_count += 1
			if (stop_count >= 10):
				return


if __name__ == '__main__':
	userInput()
