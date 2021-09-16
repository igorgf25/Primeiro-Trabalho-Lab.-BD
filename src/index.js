import sql from 'mssql'
import { sqlConfig } from './sql/config.js'


sql.on('error', err => {
    console.error(err)
})

sql.connect(sqlConfig).then(pool => {
    return pool.request()
    .input('nome', sql.VarChar(100) , 'Arroz')
    .input('descricao', sql.VarChar(500) , 'Arroz Canil')
    .input('preco_compra', sql.Numeric , 10.50)
    .input('preco_venda', sql.Numeric , 14.50)
    .input('codigo_barras', sql.BigInt , 1234567890)
    .execute('SP_I_LOJ_PRODUTO')
}).then(result => {
    console.log(result)
}).catch(err => {
    console.log(err.message)
})
