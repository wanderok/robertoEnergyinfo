#WANDER 25/11/23
#LUCIANO 25/11/23
#RPA swarm - Reynolds Roles

import pygame
import random
import math
import cv2
import numpy as np

# Inicialização do Pygame
pygame.init()

# Tamanho da tela
LARGURA = 1366
ALTURA = 768

# Inicialização da tela
tela = pygame.display.set_mode((LARGURA, ALTURA))
pygame.display.set_caption("Boids com Rastro e Vídeo")

# Parâmetros dos boids
NUM_BOIDS = 2 #50 (up and side drones)
BOID_RADIUS = 5
BOID_SPEED = 2
BOID_RADIUS_COHESION = 100
BOID_RADIUS_ALIGNMENT = 50
BOID_RADIUS_SEPARATION = 20

# Cores
PRETO = (0, 0, 0)
BRANCO = (255, 255, 255)
VERMELHO = (255, 0, 0)

# Função para criar um boid
def criar_boid():
    x = random.randint(0, LARGURA)
    y = random.randint(0, ALTURA)
    angulo = random.uniform(0, 2 * math.pi)
    return [(x, y), angulo]

# Função para mover um boid
def mover_boid(boid):
    x, y = boid[0]
    angulo = boid[1]
    x += BOID_SPEED * math.cos(angulo)
    y += BOID_SPEED * math.sin(angulo)
    boid[0] = (x % LARGURA, y % ALTURA)

# Função para desenhar um boid
def desenhar_boid(tela, boid):
    x, y = boid[0]
    pygame.draw.circle(tela, VERMELHO, (int(x), int(y)), BOID_RADIUS)

# Carregar vídeo
# cap = cv2.VideoCapture('seu_video.mov')
cap = cv2.VideoCapture('SIM_UP.MOV')

# Loop principal
rodando = True
boids = [criar_boid() for _ in range(NUM_BOIDS)]
superficie_rastro = pygame.Surface((LARGURA, ALTURA), pygame.SRCALPHA)

while rodando:
    # Verificar eventos
    for evento in pygame.event.get():
        if evento.type == pygame.QUIT:
            rodando = False

    # Ler frame do vídeo
    ret, frame = cap.read()
    if not ret:
        cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
        continue
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    frame = cv2.resize(frame, (LARGURA, ALTURA), interpolation=cv2.INTER_AREA)
    frame = np.rot90(frame)
    frame = pygame.surfarray.make_surface(frame)
    tela.blit(frame, (0, 0))
    
    # Atualizar boids
    for boid in boids:
        pos_antiga = boid[0]
        mover_boid(boid)
        pos_nova = boid[0]
        pygame.draw.line(superficie_rastro, VERMELHO, pos_antiga, pos_nova, 2)

    # Desenhar rastro
    tela.blit(superficie_rastro, (0, 0))
    
    # Desenhar boids
    for boid in boids:
        desenhar_boid(tela, boid)

    # Atualizar tela
    pygame.display.flip()

# Finalização
pygame.quit()
cap.release()