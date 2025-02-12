#WANDER 25/11/23
#LUCIANO 25/11/23
#Buffer Control

from pymavlink import mavutil
import time
import math

# Funções anteriores: create_connection, arm_drone, takeoff_drone, apply_boids_rules

# Função para enviar comandos de movimento ao drone
def send_movement_command(master, vx, vy, vz):
    master.mav.set_position_target_local_ned_send(
        0, # time_boot_ms (unused)
        master.target_system, master.target_component,
        mavutil.mavlink.MAV_FRAME_LOCAL_NED, # frame
        0b0000111111000111, # type_mask (only positions enabled)
        0, 0, 0, # x, y, z positions (not used)
        vx, vy, vz, # x, y, z velocity in m/s
        0, 0, 0, # x, y, z acceleration (not used)
        0, 0) # yaw, yaw_rate (not used)

# Função para atualizar a posição do drone com base no vetor de movimento
def update_drone_position(master, move_vector):
    vx, vy = move_vector
    vz = 0 # Mantém a mesma altitude por simplicidade
    send_movement_command(master, vx, vy, vz)

# Código para conectar aos drones, armar e decolar...

# Exemplo de loop principal
while True:
    # Obter as posições e velocidades atuais dos drones
    # Para este exemplo, vamos usar posições e velocidades fictícias
    # getPositionX = 10
    # getPositionY = 10
    drones_positions = [[0, 0], [getPositionX(), getPositionY()]] 
    my_position = [5, 5] # Posição do drone atual
    my_velocity = [1, 1] # Velocidade do drone atual

    # Aplicar as regras de boids
    move_vector = apply_boids_rules(drone1, drones_positions, my_position, my_velocity, 5) # Max velocity = 5 m/s

    # Atualizar a posição do drone
    update_drone_position(drone1, move_vector)

    # Pausa entre comandos
    time.sleep(1)

