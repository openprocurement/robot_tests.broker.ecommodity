# -*- coding: utf-8 -*-
import dateutil.parser
from datetime import datetime
from pytz import timezone
import os
import urllib
import re

def ecommodity_convertdate(isodate):
    date = dateutil.parser.parse(isodate)
    return date.strftime("%d.%m.%Y %H:%M")

def ecommodity_convertdateS(isodate):
    date = dateutil.parser.parse(isodate)
    return date.strftime("%d.%m.%Y %H:%M:%S")

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

def convert_iso8601Duration(duration):
   if duration == u'P1M':
    duration = u'P30D'
   dayDuration = re.search('\d+D|$', duration).group()
   if len(dayDuration) > 0:
    dayDuration = dayDuration[:-1]
   return dayDuration

def ecommodity_set_custodian(tender_data):
   tender_data['data']['assetCustodian']['identifier']['scheme'] = u'UA-EDR'
   tender_data['data']['assetCustodian']['identifier']['id'] = u'57846287'
   tender_data['data']['assetCustodian']['identifier']['legalName'] = u'BIT Production Ltd.'
   tender_data['data']['assetCustodian']['name'] = u'BIT Production Ltd.'
   tender_data['data']['assetCustodian']['contactPoint']['name'] = u'Тестер Тест Тестович'
   tender_data['data']['assetCustodian']['contactPoint']['telephone'] = u'+38 (056) 373-95-99'
   tender_data['data']['assetCustodian']['contactPoint']['email'] = u'bitassetcustodian@i.ua'
   tender_data['data']['assetCustodian']['address']['countryName'] = u'Україна'
   return tender_data

def convert_CAVMP(string):
    return {
            '08110000-0': '301',
            '08160000-5': '302',
            }.get(string, string)

def convert_ecommodity_accelerator_from_string(str_accelerator):
    return re.findall(r'\d+', str_accelerator)[-1]

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
            u'ASSET_Чернетка':                                              'draft',
            u'ASSET_Опубліковано. Очікування інформаційного повідомлення':  'pending',
            u'ASSET_Публікація інформаційного повідомлення':                'verification',
            u'ASSET_Інформаційне повідомлення опубліковано':                'active',
            u'ASSET_Аукціон завершено':                                     'complete',
            u'ASSET_Виключено з переліку':                                  'deleted',
            u'LOT_Чернетка':                                                'draft',
            u'LOT_Перевірка доступності об’єкту':                           'composing',
            u'LOT_Перевірка коректності оголошення':                        'verification',
            u'LOT_Опубліковано':                                            'pending',
            u'LOT_Об’єкт виставлено на продаж':                             'active.salable',
            u'LOT_Аукціон':                                                 'active.auction',
            u'LOT_Аукціон завершено. Кваліфікація':                         'active.contracting',
            u'LOT_Аукціон завершено':                                       'pending.sold',
            u'LOT_Об’єкт продано':                                          'sold',
            u'LOT_Аукціон завершено. Об’єкт не продано':                    'pending.dissolution',
            u'LOT_Об’єкт не продано':                                       'dissolved',
            u'LOT_Об’єкт в процесі виключення':                             'pending.deleted',
            u'LOT_Об’єкт виключено':                                        'deleted',
            u'LOT_Недійсний':                                               'invalid',
            u'SELLOUT_Аукціон малої приватизації':                          'sellout.english',
            u'SELLOUT_Аукціон із зниженням стартової ціни':                 'sellout.english',
            u'SELLOUT_Аукціон за методом покрокового зниження стартової ціни та подальшого подання цінових пропозицій':   'sellout.insider',
            u'SELLOUT_Прийняття заяв на участь':             'active.tendering',
            u'SELLOUT_Аукціон':                              'active.auction',
            u'SELLOUT_Очікується опублікування протоколу':   'active.qualification',
            u'SELLOUT_Очікується опублікування договору':    'active.awarded',
            u'SELLOUT_Аукціон не відбувся':                  'unsuccessful',
            u'SELLOUT_Аукціон відбувся':                     'complete',
            u'SELLOUT_Аукціон відмінено':                    'cancelled',
            u'SELLOUT_Чернетка':                             'draft',
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
            'notice': '1',
            'technicalSpecifications': '3',
            'contractSigned': '17',
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
            'cancellationDetails': '38',
            'admissionProtocol': '41',
            'rejectionProtocol': '42',
            'act': '43',
            }.get(string, string)
