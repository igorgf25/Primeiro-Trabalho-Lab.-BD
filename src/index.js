import express from 'express'
const app = express()
const port = 4000

app.use(express.urlencoded({extended: true}))
app.use(express.json())
app.disable('x-powered-by')

import rotasProdutos from './routes/produtos.js'

app.use('/api/produtos', rotasProdutos)

app.get('/api', (req, res) => {
    res.status(200).json({
        mensagem: 'Api funcionando!',
        versao: '1.0.0'
    })
})

app.use('/', express.static('public'))

app.use(function(req, res){
    res.status(404).json({
        mensagem: `A rota ${req.originalUrl} não existe!`
    })
})

app.listen(port, function(){
    console.log(`Servidor web rodando na porta ${port}`)
})