const express = require('express');
const cors = require('cors');
const path = require('path');
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const bcrypt = require('bcrypt'); 

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true })); //Necesario para mandar el formulario de registro por el body
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

db.settings({
    ignoreUndefinedProperties: true //necesario para poder poner los campos de POST a null
  });

  function acortarDescripcion(descripcion) {
    if (!descripcion) return "";  
    const limitePalabras = 10;
    const palabras = descripcion.split(' ');
    return palabras.length > limitePalabras ?
      palabras.slice(0, limitePalabras).join(' ') + '...' :
      descripcion;
  }
  
// Endpoint para obtener todas las categorías con todos los productos incluidos
app.get('/json', async (req, res) => {
    try {
        const categoriasSnapshot = await db.collection('categoria').get();
        const categorias = [];

        // Bucle para obtener categorías
        for (const categoriaDoc of categoriasSnapshot.docs) {
            const categoriaDatos = categoriaDoc.data();
            const productosSnapshot = await db.collection(`categoria/${categoriaDoc.id}/productos`).get();
            const productos = [];

            // Bucle para obtener productos de cada categoría
            for (const productoDoc of productosSnapshot.docs) {
                productos.push({
                    id: productoDoc.id,
                    ...productoDoc.data()
                });
            }

            categorias.push({
                id: categoriaDoc.id,
                ...categoriaDatos,
                productos: productos  // Incluir productos en la categoría
            });
        }

        res.json(categorias);
    } catch (error) {
        console.error('Error al obtener categorías y productos:', error);
        res.status(500).send('Error interno del servidor');
    }
});

// Endpoint para obtener todos los usuarios como JSON
app.get('/usuarios_json', async (req, res) => {
    try {
        const usuariosSnapshot = await db.collection('usuario').get();
        const usuarios = [];

        // Bucle para obtener usuarios
        for (const usuarioDoc of usuariosSnapshot.docs) {
            usuarios.push({
                id: usuarioDoc.id,
                ...usuarioDoc.data()
            });
        }

        res.json(usuarios);
    } catch (error) {
        console.error('Error al obtener usuarios:', error);
        res.status(500).send('Error interno del servidor');
    }
});



app.get('/', async (req, res) => {
    try {
      const categoriasSnapshot = await db.collection('categoria').get();
      const categorias = [];

      for (const categoriaDoc of categoriasSnapshot.docs) {
        const categoriaNombre = categoriaDoc.id;
        console.log(`Categoría encontrada: ${categoriaNombre}`); // Log de la categoría

        // Obtener el URL del icono desde el almacenamiento
        const iconoFile = `imagenesCategoria/${categoriaNombre}.png`;
        const [icono] = await bucket.file(iconoFile).getSignedUrl({
            action: 'read',
            expires: '03-09-2491'
        });

        categorias.push({
            id: categoriaNombre,
            nombre: categoriaNombre, // Usamos el ID del documento como nombre de la categoría
            icono: icono // URL del icono
        });
    }

      const productos = [];
  
      for (const categoriaDoc of categoriasSnapshot.docs) {
        const categoriaNombre = categoriaDoc.id;
        const productosSnapshot = await db.collection(`categoria/${categoriaNombre}/productos`).limit(1).get();
  
        for (const productoDoc of productosSnapshot.docs) {
          const producto = productoDoc.data();
          const [files] = await bucket.getFiles({ prefix: `imagenesReview/${categoriaNombre}/${productoDoc.id}` });
  
          let imageUrls = [];
          if (files.length > 0) {
            imageUrls = await Promise.all(files.slice(1).map(async (file) => {
              const [url] = await file.getSignedUrl({
                action: 'read',
                expires: '03-09-2491'
              });
              return url;
            }));
          }
  
          producto.images = imageUrls;
          producto.descripcion = acortarDescripcion(producto.descripcion);
  
        //  console.log(`Product ${producto.nombre} has image URLs: ${producto.images}`);
  
          productos.push({
            ...producto,
            categoria: categoriaNombre,
            id: productoDoc.id
          });
        }
      }
  
      console.log(`Productos to render: ${JSON.stringify(productos, null, 2)}`);
      res.render('index', { categorias, productos });
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
        const categoriasQuery = req.query.categorias ? req.query.categorias.split(',') : [];
        const categoriasSnapshot = await db.collection('categoria').get();
        const productos = [];
        const categorias = categoriasSnapshot.docs.map(doc => doc.id);

        if (categoriasQuery.length > 0) {
            for (const categoria of categoriasQuery) {
                const productosSnapshot = await db.collection(`categoria/${categoria}/productos`).get();
                for (const productoDoc of productosSnapshot.docs) {
                    const producto = productoDoc.data();
                    const [files] = await bucket.getFiles({ prefix: `imagenesReview/${categoria}/${productoDoc.id}` });

                    let imageUrls = [];
                    if (files.length > 0) {
                        imageUrls = await Promise.all(files.slice(1).map(async (file) => {
                            const [url] = await file.getSignedUrl({
                                action: 'read',
                                expires: '03-09-2491'
                            });
                            return url;
                        }));
                    }

                    producto.images = imageUrls;

                    productos.push({
                        ...producto,
                        categoria: categoria,
                        id: productoDoc.id
                    });
                }
            }
        } else {
            for (const categoriaDoc of categoriasSnapshot.docs) {
                const categoriaNombre = categoriaDoc.id;
                const productosSnapshot = await db.collection(`categoria/${categoriaNombre}/productos`).limit(1).get();
                for (const productoDoc of productosSnapshot.docs) {
                    const producto = productoDoc.data();
                    const [files] = await bucket.getFiles({ prefix: `imagenesReview/${categoriaNombre}/${productoDoc.id}` });

                    let imageUrls = [];
                    if (files.length > 0) {
                        imageUrls = await Promise.all(files.slice(1).map(async (file) => {
                            const [url] = await file.getSignedUrl({
                                action: 'read',
                                expires: '03-09-2491'
                            });
                            return url;
                        }));
                    }

                    producto.images = imageUrls;

                    productos.push({
                        ...producto,
                        categoria: categoriaNombre,
                        id: productoDoc.id
                    });
                }
            }
        }

        res.render('explorar', { productos, categorias });
    } catch (error) {
        console.error('Error al obtener los productos y categorías:', error);
        res.status(500).send('Error interno del servidor');
    }
});

app.get('/nuevoProducto', async (req, res) => {
    try {
        const categoriasSnapshot = await db.collection('categoria').get();
        const categorias = categoriasSnapshot.docs.map(doc => doc.id);
        res.render('nuevoProducto', { categorias });
    } catch (error) {
        console.error('Error al obtener las categorías:', error);
        res.status(500).send('Error interno del servidor');
    }
});

app.post('/nuevoProducto', async (req, res) => {
    try {
        const { nombre, descripcion, precio, categoria, imagenes, userId } = req.body;

        if (!userId) {
            return res.status(401).send('Acceso no autorizado. Debes iniciar sesión.');
        }

        const categoriaRef = db.collection(`categoria/${categoria}/productos`);
        const q = categoriaRef.orderBy('id', 'desc').limit(1);
        const querySnapshot = await q.get();
        let newId = 1;

        querySnapshot.forEach(doc => {
            newId = doc.data().id + 1;
        });

        await categoriaRef.doc(newId.toString()).set({
            id: newId,
            nombre,
            descripcion,
            precio,
            categoria,
            imagenes,
            userId // Guardar el ID del usuario
        });

        res.redirect('/explorar');
    } catch (error) {
        console.error('Error al guardar el producto:', error);
        res.status(500).send('Error interno del servidor');
    }
});


app.get('/registro', (req, res) => {
    res.render('paginaRegistro');  // Asegúrate de que el archivo se llame 'registro.ejs' en tu directorio de vistas
  });

  app.post('/registro', async (req, res) => {
    const { nombre, email, password, edad, genero, idioma, descripcion } = req.body;

    if (!nombre || !email || !password) {
        return ;
    }

    try {
        // Obtener el último ID disponible y sumar 1 para usarlo como nombre del documento
        const usersRef = db.collection('usuario');
        const querySnapshot = await usersRef.orderBy('__name__', 'desc').limit(1).get();
        let newId = '1'; // Asumimos que empezamos en '1' si no hay otros documentos

        if (!querySnapshot.empty) {
            const lastDocId = querySnapshot.docs[0].id;
            newId = String(parseInt(lastDocId) + 1); // Incrementa el último ID encontrado
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        // Prepara los datos del usuario sin incluir un campo id
        const userData = {
            nombre, email, password: hashedPassword, edad, genero, idioma, descripcion,
            rol:"usuario"
        };


        // Guardar el nuevo usuario utilizando newId como el nombre del documento
        await usersRef.doc(newId).set(userData);

        res.send('Registro completado con éxito');
    } catch (error) {
        console.error('Error al guardar los datos:', error);
        res.status(500).send('Error al procesar el registro');
    }
});

app.get('/usuario', async (req, res) => {
    const userId = req.query.id;
    try {
        const userDoc = await db.collection('usuario').doc(userId).get();
        if (userDoc.exists) {
            res.json(userDoc.data());
        } else {
            res.status(404).send('Usuario no encontrado');
        }
    } catch (error) {
        console.error('Error al obtener los datos del usuario:', error);
        res.status(500).send('Error interno del servidor');
    }
});

app.post('/login', async (req, res) => {
    const { nombre, password } = req.body;

    if (!nombre || !password) {
        return res.status(400).send('Nombre de usuario y contraseña son obligatorios');
    }

    try {
        const usersRef = db.collection('usuario');
        const userQuery = usersRef.where('nombre', '==', nombre);
        const querySnapshot = await userQuery.get();

        if (querySnapshot.empty) {
            return res.status(400).send('Usuario o contraseña incorrectos');
        }

        const userDoc = querySnapshot.docs[0];
        const userData = userDoc.data();

        // Comparar la contraseña encriptada
        const passwordMatch = await bcrypt.compare(password, userData.password);

        if (!passwordMatch) {
            return res.status(400).send('Usuario o contraseña incorrectos');
        }

        // Guardar el userId y el nombre de usuario en la respuesta
        res.status(200).send({ userId: userDoc.id, username: userData.nombre });
    } catch (error) {
        console.error('Error al autenticar el usuario:', error);
        res.status(500).send('Error al iniciar sesión');
    }
});

app.post('/mis-valoraciones', async (req, res) => {
    const userId = req.body.userId;

    if (!userId) {
        return res.status(401).send('Acceso no autorizado. Debes iniciar sesión.');
    }

    console.log("user id: " + userId);
    try {
        const categoriasSnapshot = await db.collection('categoria').get();
        const productos = [];

        for (const categoriaDoc of categoriasSnapshot.docs) {
            const categoriaNombre = categoriaDoc.id;
            const productosSnapshot = await db.collection(`categoria/${categoriaDoc.id}/productos`).where('userId', '==', userId).get();

            for (const productoDoc of productosSnapshot.docs) {
                const producto = productoDoc.data();
                const [files] = await bucket.getFiles({ prefix: `imagenesReview/${categoriaNombre}/${productoDoc.id}` });

                let imageUrls = [];
                if (files.length > 0) {
                    imageUrls = await Promise.all(files.slice(1).map(async (file) => {
                        const [url] = await file.getSignedUrl({
                            action: 'read',
                            expires: '03-09-2491'
                        });
                        return url;
                    }));
                }
                producto.images = imageUrls;
                producto.descripcion = acortarDescripcion(producto.descripcion);
                productos.push({
                    ...producto,
                    id: productoDoc.id,
                    categoria: categoriaNombre
                });
            }
        }

        // Log the number of products
        console.log(`Number of products to display: ${productos.length}`);

        res.render('mis-valoraciones', { productos });
    } catch (error) {
        console.error('Error al obtener las valoraciones:', error);
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