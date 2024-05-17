const express = require('express');
const cors = require('cors');
const path = require('path');
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());
app.set('view engine', 'ejs'); // Establece EJS como el motor de plantillas
app.set('views', path.join(__dirname,"../")); // Asegúrate que la ruta es correcta y que los archivos .ejs están ahí

// Inicializar Firebase Admin SDK
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: 'https://the-review-corner.firebaseio.com'
});

const db = admin.firestore();

// Ruta principal que carga la vista 'index.ejs'
app.get('/', (req, res) => {
    res.render('index'); // No es necesario especificar .ejs, asegúrate de tener una plantilla 'index.ejs'
});

// Ruta para obtener datos de producto basado en categoría y ID
app.get('/producto/:categoria/:id', async (req, res) => {
    const { categoria, id } = req.params;

    try {
        const productSnapshot = await db.collection('categoria').doc(categoria).collection('productos').doc(id).get();
        if (productSnapshot.exists) {
            const producto = productSnapshot.data();
            res.render('producto', { producto });
        } else {
            res.status(404).send('Producto no encontrado');
        }
    } catch (error) {
        console.error('Error al obtener el producto:', error);
        res.status(500).send('Error interno del servidor');
    }
});

// Servir archivos estáticos, asegúrate de que la ruta es correcta
app.use(express.static(path.join(__dirname, '../')));

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
    import('open').then(open => {
        open.default(`http://localhost:${port}`);
    }).catch(err => console.error('Failed to load module:', err));
});