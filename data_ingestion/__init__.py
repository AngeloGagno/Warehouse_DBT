
"""
Geração de dados sintéticos (varejo) e ingestão em PostgreSQL.

Tabelas:
- clientes(id_cliente PK, nome, email, celular)
- produtos(id_produto PK, nome, setor, preco_compra)
- matrizes(id_matriz PK, nome, endereco)
- vendas(id_venda PK, id_produto FK, valor_vendido, id_matriz FK, id_cliente FK, vendido_em)

Uso:
  python gerar_varejo.py \
    --clientes 1_000 --produtos 200 --matrizes 10 --vendas 5_000 \
    --db postgresql+psycopg2://usuario:senha@host:5432/banco \
    --schema publico --seed 42
Ou defina DATABASE_URL no ambiente e omita --db.
"""