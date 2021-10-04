CREATE DATABASE LOJA

USE LOJA


CREATE TABLE LOJ_PRODUTO(
PRO_IN_ID INT IDENTITY CONSTRAINT LOJ_PK_PRODUTO PRIMARY KEY,
PRO_ST_NOME VARCHAR(100) NOT NULL CONSTRAINT LOJ_UK_PRO_NOME UNIQUE,
PRO_ST_DESCRICAO VARCHAR(500) NOT NULL,
PRO_RE_PRECO_COMPRA NUMERIC(12, 2) NOT NULL,
PRO_RE_PRECO_VENDA NUMERIC(12, 2) NOT NULL,
PRO_RE_MARGEM_LUCRO DECIMAL(8,2) NOT NULL,
PRO_BG_CODIGO_BARRAS BIGINT NOT NULL CHECK (PRO_BG_CODIGO_BARRAS LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') CONSTRAINT LOJ_UK_PRO_CODIGO_BARRA UNIQUE,
PRO_DT_INCLUSAO DATE DEFAULT GETDATE(),
PRO_DT_VALIDADE DATE NOT NULL
)


-- STORED PROCEDURES

-- INSERT
CREATE PROCEDURE SP_I_LOJ_PRODUTO(@NOME VARCHAR(100), @DESCRICAO VARCHAR(500), @PRECO_COMPRA NUMERIC(12, 2), @PRECO_VENDA NUMERIC(12, 2), 
@CODIGO_BARRAS BIGINT, @DATA_VALIDADE DATE) AS
SET NOCOUNT ON
DECLARE @TOTAL_NOME INT
DECLARE @TOTAL_CODIGO_BARRA INT
DECLARE @MARGEN_LUCRO DECIMAL(8,2)

SELECT @TOTAL_NOME = COUNT(PRO_ST_NOME) FROM LOJ_PRODUTO WHERE UPPER(PRO_ST_NOME) = UPPER(@NOME)
SELECT @TOTAL_CODIGO_BARRA = COUNT(PRO_BG_CODIGO_BARRAS) FROM LOJ_PRODUTO WHERE PRO_BG_CODIGO_BARRAS = @CODIGO_BARRAS

IF(@TOTAL_NOME > 0)
BEGIN
	RAISERROR('Produto j� existe', 15, 1)
	RETURN
END

IF(@TOTAL_CODIGO_BARRA > 0)
BEGIN
	RAISERROR('O codigo de barras do produto j� existe', 15, 1)
	RETURN
END

IF(@NOME IS NULL OR @DESCRICAO IS NULL OR @PRECO_COMPRA IS NULL OR @PRECO_VENDA IS NULL
OR @CODIGO_BARRAS IS NULL OR @DATA_VALIDADE IS NULL)
BEGIN
	RAISERROR('Os campos Nome, Descri��o, Pre�o de Compra, Pre�o de Venda, Codigo de barras e Data de Validade s�o obrigat�rios', 15, 1)
	RETURN 
END

IF(@PRECO_COMPRA < 0)
BEGIN
	RAISERROR('Valor de compra deve ser igual ou maior que zero', 15 ,1)
	RETURN
END

IF(@PRECO_VENDA < 0)
BEGIN
	RAISERROR('Valor de venda deve ser igual ou maior que zero', 15 ,1)
	RETURN
END

IF(@DATA_VALIDADE < GETDATE())
BEGIN
	RAISERROR('Data de validade invalida', 15, 1)
	RETURN
END

SELECT @MARGEN_LUCRO = dbo.MARGEM_LUCRO(@PRECO_COMPRA, @PRECO_VENDA)

INSERT INTO LOJ_PRODUTO(PRO_ST_NOME, PRO_ST_DESCRICAO, PRO_RE_PRECO_COMPRA, PRO_RE_PRECO_VENDA, PRO_RE_MARGEM_LUCRO , PRO_BG_CODIGO_BARRAS, PRO_DT_VALIDADE) VALUES
(@NOME, @DESCRICAO, @PRECO_COMPRA, @PRECO_VENDA, @MARGEN_LUCRO , @CODIGO_BARRAS, @DATA_VALIDADE)
RETURN

EXECUTE SP_I_LOJ_PRODUTO "Macarr�o", "Macarr�o Camil", 10.45, 14.80, 1234567890, '2021-11-04'

-- UPDATE

CREATE PROCEDURE SP_U_LOJ_PRODUTO(@ID INT, @NOME VARCHAR(100), @DESCRICAO VARCHAR(500), @PRECO_COMPRA NUMERIC(12, 2), @PRECO_VENDA NUMERIC(12, 2),
@CODIGO_BARRAS BIGINT, @DATA_VALIDADE DATE) AS
SET NOCOUNT ON
DECLARE @TOTAL_NOME INT
DECLARE @TOTAL_CODIGO_BARRA INT
DECLARE @TOTAL_ID INT
DECLARE @CODIGO_ATUAL BIGINT
DECLARE @NOME_ATUAL VARCHAR(100)
DECLARE @MARGEN_LUCRO DECIMAL(8,2)

SELECT @TOTAL_NOME = COUNT(PRO_ST_NOME) FROM LOJ_PRODUTO WHERE UPPER(PRO_ST_NOME) = UPPER(@NOME)
SELECT @TOTAL_CODIGO_BARRA = COUNT(PRO_BG_CODIGO_BARRAS) FROM LOJ_PRODUTO WHERE PRO_BG_CODIGO_BARRAS = @CODIGO_BARRAS
SELECT @TOTAL_ID = COUNT(PRO_IN_ID) FROM LOJ_PRODUTO WHERE PRO_IN_ID = @ID
SELECT @CODIGO_ATUAL = PRO_BG_CODIGO_BARRAS FROM LOJ_PRODUTO WHERE PRO_IN_ID = @ID
SELECT @NOME_ATUAL = PRO_ST_NOME FROM LOJ_PRODUTO WHERE PRO_IN_ID = @ID
SELECT @MARGEN_LUCRO = dbo.MARGEM_LUCRO(@PRECO_COMPRA, @PRECO_VENDA)

IF(@TOTAL_ID = 0)
BEGIN
	RAISERROR('Produto n�o existe', 15, 1)
	RETURN
END

IF(@NOME_ATUAL != @NOME)
BEGIN
	IF(@TOTAL_NOME > 0)
	BEGIN
		RAISERROR('O nome do produto j� existe', 15, 1)
		RETURN
	END
END


IF (@CODIGO_ATUAL != @CODIGO_BARRAS)
BEGIN
	IF(@TOTAL_CODIGO_BARRA > 0)
	BEGIN
		RAISERROR('O codigo de barras do produto j� existe', 15, 1)
		RETURN
	END
END

IF(@PRECO_COMPRA < 0)
BEGIN
	RAISERROR('Valor de compra deve ser igual ou maior que zero', 15 ,1)
	RETURN
END

IF(@PRECO_VENDA < 0)
BEGIN
	RAISERROR('Valor de venda deve ser igual ou maior que zero', 15 ,1)
	RETURN
END



IF(@NOME IS NULL OR @DESCRICAO IS NULL OR @PRECO_COMPRA IS NULL OR @PRECO_VENDA IS NULL
OR @CODIGO_BARRAS IS NULL OR @DATA_VALIDADE IS NULL)
BEGIN
	RAISERROR('Os campos Nome, Descri��o, Pre�o de Compra, Pre�o de Venda, Codigo de barras e Data de Validade s�o obrigat�rios', 15, 1)
	RETURN 
END

IF(@DATA_VALIDADE < GETDATE())
BEGIN
	RAISERROR('Data de validade invalida', 15, 1)
	RETURN
END

UPDATE 
	LOJ_PRODUTO
SET
	PRO_BG_CODIGO_BARRAS = @CODIGO_BARRAS,
	PRO_RE_PRECO_COMPRA = @PRECO_COMPRA,
	PRO_RE_PRECO_VENDA = @PRECO_VENDA,
	PRO_ST_DESCRICAO = @DESCRICAO,
	PRO_ST_NOME = @NOME,
	PRO_DT_VALIDADE = @DATA_VALIDADE,
	PRO_RE_MARGEM_LUCRO = @MARGEN_LUCRO
WHERE
	PRO_IN_ID = @ID

RETURN


EXECUTE SP_U_LOJ_PRODUTO 1, "Macarr�o", "Macarr�o Camil", 10.45, 14.80, 1234567890, '2021-12-05'

-- DELETE

CREATE PROCEDURE SP_D_LOJ_PRODUTO(@ID INT) AS
DECLARE @TOTAL_ID INT

IF(DATALENGTH(@ID) = 0)
BEGIN
	RAISERROR('O campo Id � obrigat�rio', 15, 1)
	RETURN
END

SELECT @TOTAL_ID = COUNT(PRO_IN_ID) FROM LOJ_PRODUTO WHERE PRO_IN_ID = @ID

IF(@TOTAL_ID = 0)
BEGIN
	RAISERROR('Produto n�o existe', 15, 1)
	RETURN
END

DELETE 
FROM
	LOJ_PRODUTO
WHERE
	PRO_IN_ID = @ID

RETURN

-- RETORNA TODOS

CREATE PROCEDURE SP_S_LOJ_PRODUTO AS
SELECT
	PRO_IN_ID AS 'ID',
	PRO_ST_NOME AS 'Nome',
	PRO_ST_DESCRICAO AS 'Descri��o',
	PRO_RE_PRECO_COMPRA AS 'Pre�o de Compra',
	PRO_RE_PRECO_VENDA AS 'Pre�o de Venda',
	PRO_RE_MARGEM_LUCRO AS '% Margen de Lucro',
	PRO_DT_INCLUSAO AS 'Data de Inclus�o',
	PRO_BG_CODIGO_BARRAS AS 'C�digo de Barras',
	PRO_DT_VALIDADE AS 'Data de Validade',
	dbo.DIAS_VALIDADE(PRO_IN_ID) AS 'Dias At� a Validade'
FROM
	LOJ_PRODUTO AS L
ORDER BY
	TRIM(UPPER(PRO_ST_NOME))

EXECUTE SP_S_LOJ_PRODUTO

-- RETORNAR POR ID

CREATE PROCEDURE SP_S_LOJ_PRODUTO_FILTRO(@ID INT) AS
DECLARE @TOTAL_ID INT

IF(DATALENGTH(@ID) = 0)
BEGIN
	RAISERROR('O campo Id � obrigat�rio', 15, 1)
	RETURN
END

SELECT @TOTAL_ID = COUNT(PRO_IN_ID) FROM LOJ_PRODUTO WHERE PRO_IN_ID = @ID

IF(@TOTAL_ID = 0)
BEGIN
	RAISERROR('Produto n�o existe', 15, 1)
END

SELECT
	PRO_IN_ID AS 'ID',
	PRO_ST_NOME AS 'Nome',
	PRO_ST_DESCRICAO AS 'Descri��o',
	PRO_RE_PRECO_COMPRA AS 'Pre�o de Compra',
	PRO_RE_PRECO_VENDA AS 'Pre�o de Venda',
	PRO_RE_MARGEM_LUCRO AS '% Margen de Lucro',
	PRO_DT_INCLUSAO AS 'Data de Inclus�o',
	PRO_BG_CODIGO_BARRAS AS 'C�digo de Barras',
	PRO_DT_VALIDADE AS 'Data de Validade',
	dbo.DIAS_VALIDADE(PRO_IN_ID) AS 'Dias At� a Validade'
FROM
	LOJ_PRODUTO
WHERE
	PRO_IN_ID = @ID

execute SP_S_LOJ_PRODUTO_FILTRO 1

-- Function que calcula a margem de lucro

CREATE FUNCTION MARGEM_LUCRO(@preco_compra NUMERIC(12, 2), @preco_venda NUMERIC(12, 2))
RETURNS DECIMAL(8, 2)
BEGIN
	DECLARE @margen_lucro DECIMAL(8, 2);
	IF(@PRECO_COMPRA < 0)
	BEGIN
		RETURN NULL;
	END

	IF(@PRECO_VENDA < 0)
	BEGIN
		RETURN NULL;
	END	

	SELECT @margen_lucro = ((@preco_venda - @preco_compra) / @preco_venda)  * 100;
	RETURN @margen_lucro;
END

select dbo.MARGEM_LUCRO(120, 100)

-- Function calcular tempo para a data de validade

CREATE FUNCTION DIAS_VALIDADE(@ID INT)
RETURNS INT
BEGIN
	DECLARE @TEMPO_VALIDADE INT;
	DECLARE @DATA_VALIDADE DATE;
	DECLARE @COUNT_PRODUTO INT;

	SELECT @COUNT_PRODUTO = COUNT(PRO_IN_ID) FROM LOJ_PRODUTO WHERE PRO_IN_ID = @ID;

	IF(@COUNT_PRODUTO = 0)
	BEGIN
		RETURN NULL;
	END

	SELECT @DATA_VALIDADE = PRO_DT_VALIDADE FROM LOJ_PRODUTO WHERE PRO_IN_ID = @ID;

	SELECT @TEMPO_VALIDADE = DATEDIFF(day, @DATA_VALIDADE , GETDATE());

	RETURN @TEMPO_VALIDADE * -1;
END
