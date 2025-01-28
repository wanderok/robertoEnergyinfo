# Gerando gráficos

## Posição y real do VANT

### Um único gráfico

```bash
bag_graph.py -b missionZ20m.bag -y -6 6 -s /mavros/global_position/local/pose/pose/position/y
```

### Um único gráfico com duas medidas

```bash
bag_graph.py -b missionZ20m.bag -y -6 6 -s /mavros/global_position/local/pose/pose/position/y /mavros/global_position/local/pose/pose/position/z -c
```

### Dois gráficos com duas medidas

```bash
bag_graph.py -b missionZ20m.bag -y -6 6 -s /mavros/global_position/local/pose/pose/position/y /mavros/global_position/local/pose/pose/position/z
```
