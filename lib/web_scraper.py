import requests
from bs4 import BeautifulSoup

url = "https://incidentesmovilidad.cdmx.gob.mx/public/bandejaEstadoServicio.xhtml?idMedioTransporte=mb"
response = requests.get(url)
html_content = response.content
soup = BeautifulSoup(html_content, "html.parser")
div_table_wrapper = soup.find('div', {'class': 'ui-datatable-tablewrapper'})
if div_table_wrapper:
    table = div_table_wrapper.find('table')
    if table:
        thead = table.find('thead')
        if thead:
            header_row = thead.find('tr')
            header = [th.text.strip() for th in header_row.find_all('th')]
            print("Encabezado:", header)

        tbody = table.find('tbody')
        if tbody:
            rows = tbody.find_all('tr')
            for row in rows:
                cols = row.find_all('td')
                ims = row.find_all('img')
                if ims:
                    for im in ims:
                        print("Imagen:", im['src'])
                        fileName = im['src'].split('/')[-1]
                        fileName = fileName.split('?')[0].split('.')[0] + '.' + fileName.split('?')[0].split('.')[1]
                cols = [col.text.strip() for col in cols]
                print("Registro:", cols)
    else:
        print("No se encontró la tabla dentro del div.")
else:
    print("No se encontró el div con la clase 'ui-datatable-tablewrapper'.")