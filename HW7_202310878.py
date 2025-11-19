import requests
from bs4 import BeautifulSoup
import pandas as pd

request_URL = 'https://apis.data.go.kr/1360000/AsosHourlyInfoService/getWthrDataList'

# 공통 파라미터
base_params = {
    "serviceKey": "8a35df3c26378efa55c12bae453a2e5cf98a26abfbed8392b0b4095edc87b72d",
    "pageNo": "1",
    "numOfRows": "100",
    "dataType": "XML",
    "dataCd": "ASOS",
    "dateCd": "HR",
    "stnIds": "115"
}

time_ranges = {
    "range_1": {
        "startDt": "20241204",
        "startHh": "15",
        "endDt":   "20241204",
        "endHh":   "18"
    },
    "range_2": {
        "startDt": "20250604",
        "startHh": "12",
        "endDt":   "20250604",
        "endHh":   "16"
    },
    "range_3": {
        "startDt": "20251118",
        "startHh": "00",
        "endDt":   "20251118",
        "endHh":   "03"
    }
}

all_items = []

for name, tr in time_ranges.items():

    print(f"\n----- 요청 시작: {name} -----")

    params = {**base_params, **tr}

    response = requests.get(request_URL, params=params, timeout=60)

    # BeautifulSoup으로 XML 파싱
    soup = BeautifulSoup(response.text, "xml")

    items_xml = soup.find_all("item")

    if len(items_xml) == 0:
        print(f" {name}: 데이터 없음")
        continue

    # XML item → dict 변환
    for x in items_xml:
        row = {tag.name: tag.text for tag in x.find_all()}
        row["range_name"] = name
        all_items.append(row)

# 최종 DataFrame
if len(all_items) == 0:
    print("\n 모든 구간에서 데이터를 가져오지 못했습니다.")
else:
    df = pd.DataFrame(all_items)
    print("\n----- 최종 DataFrame -----")
    print(df)
