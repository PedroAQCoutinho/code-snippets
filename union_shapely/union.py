import geopandas as gpd
from shapely.geometry import Point

# Criação das feições a e b com seus respectivos buffers
a = Point(1, 1).buffer(1.5)  # Feição A
b = Point(2, 1).buffer(1.5)  # Feição B

# Criação de um GeoDataFrame com as feições e seus respectivos IDs
gdf = gpd.GeoDataFrame({
    'id': [1, 2],
    'geometry': [a, b]
})

# Realizando a operação de união entre as feições
union_geom = a.union(b)

# Criando uma lista para os IDs presentes na interseção
# Se as feições a e b se tocam ou intersectam, os IDs 1 e 2 serão incluídos
ids_in_union = gdf['id'].tolist() if not union_geom.is_empty else []

# Criando um novo GeoDataFrame para o resultado da união
gdf_union = gpd.GeoDataFrame({
    'ids': [ids_in_union],
    'geometry': [union_geom]
})

# Exibindo os dados da união e os IDs associados
print(gdf_union)
gdf_union.plot()

