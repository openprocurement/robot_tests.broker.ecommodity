# -*- coding: utf-8 -*-
import dateutil.parser
from datetime import datetime
from pytz import timezone
import os
import urllib

def ecommodity_convertdate(isodate):
    date = dateutil.parser.parse(isodate)
    return date.strftime("%d.%m.%Y %H:%M")
	
def ecommodity_remove_space(value):
    return value.replace(" ", "").replace(u' ', '')

def ecommodity_replace_todot(value):
    return value.replace(",", ".")
	
def ecommodity_convert_usnumber(value):
    return ecommodity_replace_todot(ecommodity_remove_space(value))
	
def ecommodity_contains(value1, value2):
	if value2 in value1:
		return 1
	else:
		return 0
		
def ecommodity_replace(value, strfrom, strto):
    return value.replace(strfrom, strto)
	
def ecommodity_remove(value, str):
    return ecommodity_replace(value, str, "")
	
def get_upload_file_path():
    return os.path.join(os.getcwd(), 'src/robot_tests.broker.ecommodity/eTestFileForUpload.txt')
	
def set_procuringEntity_name(tender_data, name):
   tender_data['data']['procuringEntity']['name'] = name
   return tender_data

def set_item_property(tender_data):
   for item in tender_data['data']['items']:
    if item['classification']['scheme'] == u'CAV-PS' and item['classification']['id'].startswith(u'04') or item['classification']['scheme'] == u'CPV' and item['classification']['id'].startswith(u'70'):
     item['unit']['code'] = u'MTK'
     item['unit']['name'] = u'метри квадратні'
   return tender_data

def convert_ecommodity_date_to_iso_format(date_time_from_ui):
    if date_time_from_ui.strip() == "":
       return date_time_from_ui.strip()
    new_timedata = datetime.strptime(date_time_from_ui, '%d.%m.%Y %H:%M')
    new_date_time_string = new_timedata.isoformat()
    return new_date_time_string
	
def convert_ecommodity_sdate_to_iso_format(date_time_from_ui):
    if date_time_from_ui.strip() == "":
       return date_time_from_ui.strip()
    new_timedata = datetime.strptime(date_time_from_ui, '%d.%m.%Y')
    new_date_time_string = new_timedata.isoformat()
    return new_date_time_string
	
def convert_ecommodity_sdate_to_iso_sdate_format(date_time_from_ui):
    if date_time_from_ui.strip() == "":
       return date_time_from_ui.strip()
    new_timedata = datetime.strptime(date_time_from_ui, '%d.%m.%Y')
    new_date_time_string = new_timedata.strftime("%Y-%m-%d")
    return new_date_time_string

def add_timezone_to_date(date_str):
    if date_str.strip() == "":
       return date_str.strip()
    new_date = dateutil.parser.parse(date_str)
    TZ = timezone(os.environ['TZ'] if 'TZ' in os.environ else 'Europe/Kiev')
    new_date_timezone = TZ.localize(new_date)
    return new_date_timezone.isoformat()

def convert_ecommodity_contractPeriod_to_iso_format(date_time_from_ui):
    if date_time_from_ui.strip() == "":
       return date_time_from_ui.strip()
    new_timedata = datetime.strptime(date_time_from_ui, '%d.%m.%Y')
    TZ = timezone(os.environ['TZ'] if 'TZ' in os.environ else 'Europe/Kiev')
    new_timedata = TZ.localize(new_timedata)
    new_date_time_string = new_timedata.isoformat()
    return new_date_time_string

def split_descr(str):
    return str.split(' - ')[1];

def ecommodity_download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))

def convert_ecommodity_string(string):
    return {
            'True': '1',
            'False': '0',
            u"Так": True,
            u"Hi":  False,
            u"Yes": True,
            u"No":  False,
            u"Да": True,
            u"Нет":  False,
            u'Очікування пропозицій':  'active.tendering',
            u'Період аукціону':        'active.auction',
            u'Кваліфікація переможця': 'active.qualification',
            u'Пропозиції розглянуто':  'active.awarded',
            u'Аукціон не відбувся':    'unsuccessful',
            u'Аукціон завершено':      'complete',
            u'Аукціон відмінено':      'cancelled',
            u'Чернетка':               'draft',
            u'Майна банків':           'dgfOtherAssets',
            u'Продажу':           'dgfOtherAssets',
            u'Оренди':           'dgfOtherAssets',
            u'Прав вимоги за кредитами': 'dgfFinancialAssets',
            u'Голландський аукціон':   'dgfInsider',
            u'Грн.': 'UAH',
            u'(включно з ПДВ)': True,
            u'(без ПДВ)': False,
            u'вперше': 1,
            u'вдруге': 2,
            u'третій раз': 3,
            u'четвертий раз': 4,
            u'не відомо': '',
            }.get(string, string)
			
def convert_documentType_string(string):
    return {
            'technicalSpecifications': '3',
            'commercialProposal': '22',
            'eligibilityDocuments': '24',
            'tenderNotice': '28',
            'virtualDataRoom': '29',
            'illustration': '30',
            'financialLicense': '31',
            'auctionProtocol': '32',
            'x_dgfPublicAssetCertificate': '33',
            'x_presentation': '34',
            'x_nda': '35',
            'x_dgfAssetFamiliarization': '37',
            'awardDisqualification': '38',
            }.get(string, string)
