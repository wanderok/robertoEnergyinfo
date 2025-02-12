#WANDER 25/11/23
#LUCIANO 25/11/23
#Main Control

from pymavlink import mavutil
import time
import math

# Funções anteriores: create_connection, arm_drone, takeoff_drone

# Função para calcular a distância entre dois drones
def distance(drone1_pos, drone2_pos):
    return math.sqrt((drone1_pos[0] - drone2_pos[0])**2 + (drone1_pos[1] - drone2_pos[1])**2)

# Função para aplicar as regras de enxame
def apply_boids_rules(master, drones_positions, my_position, my_velocity, max_velocity):
    # Parâmetros para as regras
    desired_separation = 10.0 # Distância mínima entre drones
    neighbor_radius = 20.0 # Raio para considerar vizinhos

    # Inicializar vetores de movimento para cada regra
    separation_vector = [0, 0]
    alignment_vector = [0, 0]
    cohesion_vector = [0, 0]

    # Contar os vizinhos próximos
    num_neighbors = 0

    for drone_pos in drones_positions:
        dist = distance(my_position, drone_pos)

        # Separação
        if 0 < dist < desired_separation:
            separation_vector[0] += my_position[0] - drone_pos[0]
            separation_vector[1] += my_position[1] - drone_pos[1]

        # Alinhamento e coesão
        if 0 < dist < neighbor_radius:
            # Alinhamento
            alignment_vector[0] += my_velocity[0]
            alignment_vector[1] += my_velocity[1]

            # Coesão
            cohesion_vector[0] += drone_pos[0]
            cohesion_vector[1] += drone_pos[1]

            num_neighbors += 1

    if num_neighbors > 0:
        # Calcular a média para alinhamento e coesão
        alignment_vector[0] /= num_neighbors
        alignment_vector[1] /= num_neighbors
        alignment_vector = [alignment_vector[0] - my_velocity[0], alignment_vector[1] - my_velocity[1]]

        cohesion_vector[0] /= num_neighbors
        cohesion_vector[1] /= num_neighbors
        cohesion_vector = [cohesion_vector[0] - my_position[0], cohesion_vector[1] - my_position[1]]

    # Normalizar e aplicar uma constante de peso para cada vetor
    separation_weight = 1.5
    alignment_weight = 1.0
    cohesion_weight = 1.0

    # Calcular o vetor de movimento final
    move_vector = [
        separation_weight * separation_vector[0] + alignment_weight * alignment_vector[0] + cohesion_weight * cohesion_vector[0],
        separation_weight * separation_vector[1] + alignment_weight * alignment_vector[1] + cohesion_weight * cohesion_vector[1]
    ]

    # Limitar a velocidade máxima
    norm = math.sqrt(move_vector[0]**2 + move_vector[1]**2)
    if norm > max_velocity:
        move_vector[0] = (move_vector[0] / norm) * max_velocity
        move_vector[1] = (move_vector[1] / norm) * max_velocity

    return move_vector

# Função para atualizar a posição do drone com base no vetor de movimento
def update_drone_position(master, move_vector):
    # Aqui você deverá implementar a lógica para atualizar a posição do drone
    # com base no vetor de movimento. Isso pode envolver o envio de comandos MAVLink
    # específicos para ajustar a posição do
