import express from 'express'
import sql from 'mssql'
import { sqlConfig } from '../sql/config.js'
const router = express.Router()

// GET Todos os Produtos
router.get("/", (req, res) => {
    try{
        sql.connect(sqlConfig).then(pool => {
            return pool.request()
            .execute('SP_S_LOJ_PRODUTO')
        }).then(dados => {
            res.status(200).json(dados.recordset)
        }).catch(err => {
            res.status(400).json(err)
        })
    } catch (err){
        console.error(err)
    }
})

// GET Um Produto em Especifico
router.get("/:id", (req, res) => {
    const id = req.params.id
    try{
        sql.connect(sqlConfig).then(pool => {
            return pool.request()
            .input('id', sql.Int, id)
            .execute('SP_S_LOJ_PRODUTO_FILTRO')
        }).then(dados => {
            res.status(200).json(dados.recordset)
        }).catch(err => {
            res.status(400).json(err.message)
        })
    } catch (err){
        console.error(err)
    }
})

// Inserindo Novo Produto
router.post("/", (req, res) => {
    sql.connect(sqlConfig).then(pool => {
        const {nome, descricao, preco_compra, preco_venda, codigo_barras, data_validade} = req.body
        return pool.request()
        .input('nome', sql.VarChar(100), nome)
        .input('descricao', sql.VarChar(200), descricao)
        .input('preco_compra', sql.Numeric(8,2), preco_compra)
        .input('preco_venda', sql.Numeric(8,2), preco_venda)
        .input('codigo_barras', sql.BigInt, codigo_barras)
        .input('data_validade', sql.Date, data_validade)
        .execute('SP_I_LOJ_PRODUTO')
    }).then(dados => {
        res.status(200).json(dados.output)
    }).catch(err => {
        res.status(400).json(err.message)
    })
})


// Atualizando Produto
router.put("/", (req, res) => {
   sql.connect(sqlConfig).then(pool => {
        const {id, nome, descricao, preco_compra, preco_venda, codigo_barras, data_validade} = req.body
        return pool.request()
        .input('id', sql.Int, id)
        .input('nome', sql.VarChar(100), nome)
        .input('descricao', sql.VarChar(200), descricao)
        .input('preco_compra', sql.Numeric(8,2), preco_compra)
        .input('preco_venda', sql.Numeric(8,2), preco_venda)
        .input('codigo_barras', sql.BigInt, codigo_barras)
        .input('data_validade', sql.Date, data_validade)
        .execute('SP_U_LOJ_PRODUTO')
    }).then(dados => {
        res.status(200).json('Produto alterado com sucesso!')
    }).catch(err => {
        res.status(400).json(err.message)
    })
})

//Apagando Produto
router.delete('/:id', (req, res) => {
    sql.connect(sqlConfig).then(pool => {
        const id = req.params.id
        return pool.request()
        .input('id', sql.Int, id)
        .execute('SP_D_LOJ_PRODUTO')
    }).then(dados => {
        res.status(200).json('Produto excluído com sucesso!')
    }).catch(err => {
        res.status(400).json(err.message)
    })
})

export default router