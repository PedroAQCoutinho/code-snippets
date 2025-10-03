import requests

prefixos = [
    "sicar_imoveis",
    "sicar_app",
    "sicar_reserva_legal",
    "sicar_rl",
    "sicar_areas_protegidas",
    "sicar_areas_preservacao",
    "sicar_vegetacao",
    "sicar_cursos_dagua",
    "sicar_uso_solo",
    "sicar_perimetro_irrigado",
    "sicar_divisa_municipal",
    "sicar_ponto_monitoramento",
    "sicar_ponto_amostral",
    "sicar_zona_rural",
    "sicar_areas_uso_sustentavel",
    "sicar_limite_bioma",
    "sicar_bosque_protegido",
    "sicar_cobertura_fluvial",
    "sicar_ponto_teste",
    "sicar_area_consolidada",
    "sicar_area_degradada",
    "sicar_zona_tombamento",
    "sicar_zona_protegida",
    "sicar_estradas",
    "sicar_rios",
    "sicar_reservas_indigenas",
    "sicar_unidade_conservacao",
    "sicar_plantio_manejo",
    "sicar_cultura_agricola",
    "sicar_patrimonio_historico"
]

estado = "ac"
base_url = "https://geoserver.car.gov.br/geoserver/sicar/ows"

def testa_camada(camada):
    params = {
        "service": "WFS",
        "version": "2.0.0",
        "request": "GetFeature",
        "typename": f"sicar:{camada}",
        "outputFormat": "application/json",
        "maxFeatures": "1"
    }
    try:
        r = requests.get(base_url, params=params, verify=False, timeout=10)
        if r.status_code == 200 and len(r.content) > 100:
            print(f"[OK] Camada encontrada: {camada}")
            return True
        else:
            print(f"[X] Não existe ou vazia: {camada}")
            return False
    except Exception as e:
        print(f"[!] Erro na camada {camada}: {e}")
        return False

if __name__ == "__main__":
    for prefixo in prefixos:
        nome_camada = f"{prefixo}_{estado}"
        testa_camada(nome_camada)
