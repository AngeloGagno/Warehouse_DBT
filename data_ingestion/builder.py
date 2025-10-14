#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from __future__ import annotations
from sqlalchemy import (
    MetaData, Table, Column, Integer, String, Numeric, ForeignKey,
    DateTime, Index
)



def build_tables(metadata: MetaData, schema: str | None = None):
    clientes = Table(
        "clientes", metadata,
        Column("id_cliente", Integer, primary_key=True, autoincrement=True),
        Column("nome", String(150), nullable=False),
        Column("email", String(200), nullable=False, unique=True),
        Column("celular", String(30), nullable=False),
        schema=schema
    )

    produtos = Table(
        "produtos", metadata,
        Column("id_produto", Integer, primary_key=True, autoincrement=True),
        Column("nome", String(200), nullable=False),
        Column("setor", String(50), nullable=False),
        Column("preco_compra", Numeric(10, 2), nullable=False),
        schema=schema
    )

    matrizes = Table(
        "matrizes", metadata,
        Column("id_matriz", Integer, primary_key=True, autoincrement=True),
        Column("nome", String(150), nullable=False),
        Column("endereco", String(250), nullable=False),
        schema=schema
    )

    vendas = Table(
        "vendas", metadata,
        Column("id_venda", Integer, primary_key=True, autoincrement=True),
        Column("id_produto", Integer, ForeignKey((f"{schema}." if schema else "") + "produtos.id_produto"), nullable=False),
        Column("valor_vendido", Numeric(10, 2), nullable=False),
        Column("id_matriz", Integer, ForeignKey((f"{schema}." if schema else "") + "matrizes.id_matriz"), nullable=False),
        Column("id_cliente", Integer, ForeignKey((f"{schema}." if schema else "") + "clientes.id_cliente"), nullable=False),
        Column("vendido_em", DateTime, nullable=False, index=True),
        schema=schema
    )

    Index("ix_produtos_setor", produtos.c.setor)
    Index("ix_clientes_email", clientes.c.email, unique=True)
    Index("ix_vendas_ids", vendas.c.id_produto, vendas.c.id_matriz, vendas.c.id_cliente)

    return clientes, produtos, matrizes, vendas