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
    databaseURL: 'https://the-review-corner.firebaseio.com',
    storageBucket: 'the-review-corner.appspot.com'
});

// Obtener referencia al bucket de almacenamiento
const bucket = admin.storage().bucket();

// Servir la aplicación Flutter en la subruta /flutter
app.use('/flutter', express.static(path.join(__dirname, '../thefluttercorner-1/build/web')));

const db = admin.firestore();

// Ruta principal que carga la vista 'index.ejs'
app.get('/', async (req, res) => {
    try {
        const categoriasSnapshot = await db.collection('categoria').get();
        const productos = [];

        for (const categoriaDoc of categoriasSnapshot.docs) {
            const categoriaNombre = categoriaDoc.id;
            const productosSnapshot = await db.collection(`categoria/${categoriaNombre}/productos`).limit(1).get();

            for (const productoDoc of productosSnapshot.docs) {
                const producto = productoDoc.data();
                const [files] = await bucket.getFiles({ prefix: `imagenesReview/${categoriaNombre}/${productoDoc.id}` });

                if (files.length > 0) {
                    const [url] = await files[0].getSignedUrl({
                        action: 'read',
                        expires: '03-09-2491'
                    });

                    // Agrega un log para verificar la URL generada
                    console.log(`Generated URL for product ${productoDoc.id}: ${url}`);

                    producto.imageUrl = url;
                } else {
                    console.log(`No files found for product ${productoDoc.id}`);
                }

                productos.push({
                    ...producto,
                    categoria: categoriaNombre,
                    id: productoDoc.id
                });
            }
        }

        console.log(`Productos to render: ${JSON.stringify(productos, null, 2)}`);
        res.render('index', { productos });
    } catch (error) {
        console.error('Error al obtener los productos:', error);
        res.status(500).send('Error interno del servidor');
    }
});


// Ruta para obtener datos de producto basado en categoría y ID
app.get('/producto/:categoria/:id', async (req, res) => {
    const { categoria, id } = req.params;

    try {
        const productSnapshot = await db.collection('categoria').doc(categoria).collection('productos').doc(id).get();
        if (productSnapshot.exists) {
            const producto = productSnapshot.data();

            // Get image URLs from Firebase Storage
            const [files] = await bucket.getFiles({
                prefix: `imagenesReview/${categoria}/${id}`
            });

            // Assuming files is an array of objects
            const imageUrls = await Promise.all(files.slice(1).map(async (file) => {  // Start from the second element
                const [url] = await file.getSignedUrl({
                    action: 'read',
                    expires: '03-09-2491'
                });
                return url;
            }));

            producto.images = imageUrls;

            res.render('producto', { producto });
        } else {
            res.status(404).send('Producto no encontrado');
        }
    } catch (error) {
        console.error('Error al obtener el producto:', error);
        res.status(500).send('Error interno del servidor');
    }
});

app.get('/explorar', async (req, res) => {
    try {
      const reviewsSnapshot = await db.collection('reviews').get();
      const reviews = [];
  
      for (const doc of reviewsSnapshot.docs) {
        const review = doc.data();
        const [files] = await bucket.getFiles({ prefix: `imagenesReview/${doc.id}/` });
  
        if (files.length > 0) {
          const [url] = await files[0].getSignedUrl({
            action: 'read',
            expires: '03-09-2491'
          });
          review.imageUrl = url;
        }
  
        reviews.push(review);
      }
  
      res.render('explorar', { reviews });
    } catch (error) {
      console.error('Error getting reviews:', error);
      res.status(500).send('Error loading reviews');
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