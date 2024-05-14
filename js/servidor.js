const express = require('express');
const cors = require('cors');
const path = require('path');
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json'); // Ruta al archivo de claves JSON

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

// Inicializar Firebase Admin SDK
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://the-review-corner.firebaseio.com'
});

const db = admin.firestore();

// Servir la página HTML básica
app.use(express.static(path.join(__dirname, '../')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../index.html'));
});

// Servir la aplicación Flutter en la subruta /flutter
app.use('/flutter', express.static(path.join(__dirname, '../thefluttercorner-1/build/web')));

// Ruta para obtener datos de producto basado en categoría y ID
app.get('/categoria/:categoria/:id', async (req, res) => {
    const { categoria, id } = req.params;

    try {
        const productSnapshot = await db.collection('categoria').doc(categoria).collection('productos').doc(id).get();
        if (productSnapshot.exists) {
            // Enviar los datos a la página de producto, por ejemplo renderizando la página con un template
            res.render('producto', { producto: productSnapshot.data() }); // Esto requeriría un motor de plantillas como ejs, pug, etc.
        } else {
            res.status(404).send('Producto no encontrado');
        }
    } catch (error) {
        console.error('Error al obtener el producto:', error);
        res.status(500).send('Error interno del servidor');
    }
});


app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
    import('open').then(open => {
        open.default(`http://localhost:${port}`);
    }).catch(err => console.error('Failed to load module:', err));
});
