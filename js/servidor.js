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

// Ruta de la API para obtener los datos de un producto según su ID
app.get('/api/productos/:id', async (req, res) => {
    const productId = req.params.id;
    const productRef = db.collection('productos').doc(productId);

    try {
        const productSnapshot = await productRef.get();
        if (productSnapshot.exists) {
            res.json(productSnapshot.data());
        } else {
            res.status(404).json({ error: 'Producto no encontrado' });
        }
    } catch (error) {
        console.error('Error al obtener el producto:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    }
});

// Servir la página del producto con los datos correspondientes
app.get('/productos/:id', (req, res) => {
    res.sendFile(path.join(__dirname, '../producto.html'));
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
    import('open').then(open => {
        open.default(`http://localhost:${port}`);
    }).catch(err => console.error('Failed to load module:', err));
});
