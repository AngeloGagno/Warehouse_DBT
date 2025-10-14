from sqlalchemy import (
    create_engine, MetaData, text
)
from sqlalchemy.engine import Engine
from sqlalchemy.exc import SQLAlchemyError
import argparse
import random 
from faker import Faker
from data_generators import *
import os
from builder import build_tables
from dotenv import load_dotenv

def ensure_schema(engine: Engine, schema: str | None):
    if not schema or schema.lower() in {"public", "publico", "público"}:
        return
    with engine.begin() as conn:
        conn.execute(text(f'CREATE SCHEMA IF NOT EXISTS "{schema}"'))

def main():
    _ = load_dotenv(override=True)
    parser = argparse.ArgumentParser(description="Gerar dados de varejo e inserir em PostgreSQL.")
    parser.add_argument("--clientes", type=int, default=500, help="Quantidade de clientes (default: 500)")
    parser.add_argument("--produtos", type=int, default=150, help="Quantidade de produtos (default: 150)")
    parser.add_argument("--matrizes", type=int, default=8, help="Quantidade de matrizes (default: 8)")
    parser.add_argument("--vendas", type=int, default=3000, help="Quantidade de vendas (default: 3000)")
    parser.add_argument("--schema", type=str, default="public", help="Schema destino (default: public)")
    parser.add_argument("--seed", type=int, default=123, help="Seed aleatória para reprodutibilidade")
    args = parser.parse_args()

    if not args.db:
        raise SystemExit(
            "Erro: informe a conexão com --db ou defina a variável de ambiente DATABASE_URL.\n"
            "Ex.: postgresql+psycopg2://usuario:senha@localhost:5432/meubanco"
        )

    random.seed(args.seed)
    fk = Faker("pt_BR")
    Faker.seed(args.seed)

    engine = create_engine(args.db, pool_pre_ping=True)

    try:
        ensure_schema(engine, args.schema)

        metadata = MetaData()
        clientes_tbl, produtos_tbl, matrizes_tbl, vendas_tbl = build_tables(metadata, schema=args.schema if args.schema != "public" else None)

        metadata.create_all(engine)

        clientes = gerar_clientes(fk, args.clientes)
        produtos = gerar_produtos(fk, args.produtos)
        matrizes = gerar_matrizes(fk, args.matrizes)

        with engine.begin() as conn:
            res_clientes = conn.execute(clientes_tbl.insert().returning(clientes_tbl.c.id_cliente), clientes)
            cliente_ids = [row[0] for row in res_clientes]

            res_produtos = conn.execute(produtos_tbl.insert().returning(produtos_tbl.c.id_produto, produtos_tbl.c.preco_compra), produtos)
            produto_ids = []
            preco_por_produto = {}
            for pid, preco in res_produtos:
                produto_ids.append(pid)
                preco_por_produto[pid] = preco

            res_matrizes = conn.execute(matrizes_tbl.insert().returning(matrizes_tbl.c.id_matriz), matrizes)
            matriz_ids = [row[0] for row in res_matrizes]

            vendas = gerar_vendas(
                fk=fk,
                n=args.vendas,
                produto_ids=produto_ids,
                cliente_ids=cliente_ids,
                matriz_ids=matriz_ids,
                preco_por_produto=preco_por_produto
            )
            conn.execute(vendas_tbl.insert(), vendas)

        print("✅ Dados gerados e inseridos com sucesso!")
        print(f"Resumo: clientes={len(clientes)} | produtos={len(produtos)} | matrizes={len(matrizes)} | vendas={len(vendas)}")
        print(f"Schema: {args.schema}")

    except SQLAlchemyError as e:
        print("❌ Erro de banco de dados:", e)
        raise
    except Exception as e:
        print("❌ Erro:", e)
        raise

if __name__ == "__main__":
    main()
