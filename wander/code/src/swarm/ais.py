#WANDER 25/11/23
#LUCIANO 25/11/23
# Action Identification and Store (AIS)

from pymavlink import mavutil
import time

# Funções anteriores: create_connection, arm_drone, takeoff_drone, etc.

# Função para criar uma conexão MAVLink
def create_connection(connection_string):
    master = mavutil.mavlink_connection(connection_string, baud=57600)
    master.wait_heartbeat()
    return master

# Conectar ao drone
ip_address1 = 'tcp:127.0.0.1:14550' # Exemplo de endereço de conexão
ip_address2 = 'tcp:127.0.0.1:14551' # Exemplo de endereço de conexão
drone1 = create_connection(ip_address1) 
drone2 = create_connection(ip_address2) 

# Função para ler e processar mensagens de telemetria
def read_telemetry_data(master):
    while True:
        try:
            # Ler uma mensagem
            msg = master.recv_match(blocking=True)
            if msg is not None:
                # Processar mensagens de posição
                if msg.get_type() == 'GLOBAL_POSITION_INT':
                    latitude = msg.lat / 1e7
                    longitude = msg.lon / 1e7
                    altitude = msg.alt / 1000.0
                    print(f"Latitude: {latitude}, Longitude: {longitude}, Altitude: {altitude}")

                # Processar mensagens de atitude
                elif msg.get_type() == 'ATTITUDE':
                    pitch = math.degrees(msg.pitch)
                    roll = math.degrees(msg.roll)
                    yaw = math.degrees(msg.yaw)
                    print(f"Pitch: {pitch}, Roll: {roll}, Yaw: {yaw}")

                # Adicionar aqui processamento para outras mensagens conforme necessário

        except KeyboardInterrupt:
            break

# Iniciar a leitura de dados de telemetria
read_telemetry_data(drone1)
read_telemetry_data(drone2)
