from decimal import Decimal
from faker import Faker
from dateutil.relativedelta import relativedelta
from datetime import datetime, timedelta
import random
from utils import money
SETORS = [
    "Alimentos", "Bebidas", "Higiene", "Limpeza", "Perfumaria",
    "Eletrônicos", "Eletroportáteis", "Vestuário", "Calçados", "Papelaria",
    "Pet", "Brinquedos", "Automotivo"
]

PROD_PREFIXOS = [
    "Premium", "Eco", "Smart", "Max", "Ultra", "Plus", "Light", "Pro"
]

def gerar_clientes(fk: Faker, n: int):
    dados = []
    for _ in range(n):
        nome = fk.name()
        base_email = fk.free_email()
        usuario, dominio = base_email.split("@")
        email = f"{usuario}.{fk.random_number(digits=6)}@{dominio}".lower()
        celular = fk.msisdn() 
        dados.append({
            "nome": nome,
            "email": email,
            "celular": celular
        })
    return dados

def gerar_produtos(fk: Faker, n: int):
    dados = []
    for _ in range(n):
        setor = random.choice(SETORS)
        nome_base = fk.word().capitalize()
        nome = f"{random.choice(PROD_PREFIXOS)} {nome_base}"
        if setor in {"Alimentos", "Bebidas", "Papelaria", "Limpeza", "Higiene"}:
            preco = random.uniform(2.0, 60.0)
        elif setor in {"Vestuário", "Calçados", "Perfumaria", "Pet", "Brinquedos"}:
            preco = random.uniform(30.0, 400.0)
        elif setor in {"Eletrônicos", "Eletroportáteis", "Automotivo"}:
            preco = random.uniform(150.0, 4000.0)
        else:
            preco = random.uniform(10.0, 500.0)
        dados.append({
            "nome": nome,
            "setor": setor,
            "preco_compra": money(preco)
        })
    return dados

def gerar_matrizes(fk: Faker, n: int):
    dados = []
    for i in range(n):
        nome = f"Matriz {fk.city()} {i+1}"
        endereco = f"{fk.street_name()}, {fk.building_number()} - {fk.city()} - {fk.state_abbr()} - CEP {fk.postcode()}"
        dados.append({
            "nome": nome,
            "endereco": endereco
        })
    return dados

def gerar_vendas(
    fk: Faker,
    n: int,
    produto_ids: list[int],
    cliente_ids: list[int],
    matriz_ids: list[int],
    preco_por_produto: dict[int, Decimal]
):
    dados = []
    agora = datetime.now()
    inicio_janela = agora - relativedelta(months=6)
    for _ in range(n):
        id_produto = random.choice(produto_ids)
        id_cliente = random.choice(cliente_ids)
        id_matriz = random.choice(matriz_ids)

        # Valor de venda: markup simples 10% a 120% sobre preço de compra
        base = float(preco_por_produto[id_produto])
        markup = random.uniform(1.10, 2.20)
        valor_vendido = money(base * markup)

        # Data de venda aleatória na janela de 6 meses
        delta = agora - inicio_janela
        vendido_em = inicio_janela + timedelta(seconds=random.randint(0, int(delta.total_seconds())))

        dados.append({
            "id_produto": id_produto,
            "valor_vendido": valor_vendido,
            "id_matriz": id_matriz,
            "id_cliente": id_cliente,
            "vendido_em": vendido_em
        })
    return dados