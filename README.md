Hacker Books
============

La primera carga del JSON
--------------------------
La primera vez que carga los datos de remoto la aplicación tarda un poco. Una vez cargados los guarda en local para futuros accesos (toda la lógica en JSONProcessing). 


Implemento la funcion `loadDta()`, que con `loadFromLocalFile()` que me permite intentar cargar los datos desde local. Si no consigue cargarlo lo descargo desde internet con `loadFromInternet()`  y lo guardo en un fichero local para futuro acceso.

```swift
func loadData(fromUrl url: NSURL) throws -> JSONArray {
    var data: NSData?

    do {
        if let localData = try loadFromLocalFile(fileName: "data", withExtension: "json") {
            data = localData
        } else {
            if let inetData = try? loadFromInternet(url) {
                data = inetData
            } else {
                throw HackerBooksError.ErrorLoadingData("No se puede cargar ningún dato")
            }
        }
    } catch {
            throw HackerBooksError.ErrorLoadingData("NO se han podido cargar los datos")
    }

    if  let d: NSData = data!,
        let jsonArray = try? dataToJson(d) {
        return jsonArray
    } else {
        throw HackerBooksError.JSONParsingError
    }    
}

func loadFromLocalFile(fileName name: String, withExtension ext: String) throws -> NSData? {
    let fm = NSFileManager.defaultManager()
    do {
        print("Cargando datos desde cache...")
        var url = try fm.URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
        url = url.URLByAppendingPathComponent("data.json")
        return NSData(contentsOfURL: url)
    } catch {
        throw HackerBooksError.ErrorLoadingData("Desde fichero local")
    }
}



func loadFromInternet(url: NSURL) throws -> NSData {
    if let  data = NSData(contentsOfURL: url) {
        do {
            try saveData(data)
        }catch{
            print("No se han podido guardar los datos")
        }
        return data
    } else {
        throw HackerBooksError.JSONParsingError
    }

}
```

Estas funciones se llaman desde AppDelegate:

```swift
let json = try loadData(fromUrl: NSURL(string:"https://t.co/K9ziV0z3SJ")!)
```

Modelo de datos
---------------
El modelo de datos se carga recorriendo el array de libros y almacenando cada uno en un diccionario del tipo [Tag:[BookSet]]

```swift
// Library.swift
init(books: BooksArray){
    self.books = books
    self.books.sortInPlace()
    
    for book in self.books {
        // Reparto los libros en su tag dentro del Dicionario [tag: arrayDeLibros]
        if book.tags.count > 0 { //El libro lleva tags
            for tag in book.tags {
                addBook(book, toTag: tag)
            }
        } else { // El libro no lleva tags, lo añadimos a noTag
            addBook(book, toTag: Library.noTag)
        }
        
    }
    // Añado libros al tag Favoritos si corresponde
    loadFavorites()
    // Cargo el array de tags para poder recuperarlos en e Tableview
    loadTags()
}
```

Una vez recorrido el array de libros recorro otra vez el mismo array para detectar favoritos y añadirlos al 

También genero un array de Tags para poder crear y ordenar las secciones del TableView posteriormente.

Nota: He creado un Tag llamado NoTag. La intención es almacenar ahí libros que no tengan tags. Al final no he podido probarlo pero en verano quiero crear mi propio backend para guardar "mis" PDFs. 


Carga de datos (Imágenes y PDF) en local
----------------------------------------
Se realiza la carga de la imágen según se va necesitando en el modelo. Para ello creo una propiedad "computada" y en su método get implemento la carga remota de la imagen y su posterior guardado en local.

La estrategia para las imágenes y PDFs ha sido la misma:

```swift
// En Book.swift
let bookURL : NSURL
    var bookPDF: NSData? {
        get {
            // Intento cargar imagen desde Cache
            guard let _bookData = tryLoadFromCache(withContentsOfURL: bookURL) else {
                return nil
            }
            return _bookData
        }
    }
func tryLoadFromCache(withContentsOfURL url: NSURL) -> NSData? {
        do {
            // Intento obtener la extensión del fichero. Si no se puede aborto (sin imagen)
            guard let ext = url.pathExtension else {
                return nil
            }
            // Obtengo ref a FileManager
            let fm = NSFileManager.defaultManager() // FileManager

            print("Cargando datos desde caché...(\(String(url)))")
            
            // Obtengo Path local de cache (guardo como hash + extensión de fichero, así evito problemas con posibles nombres de fichero iguales)
            var localURL = try fm.URLForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
            localURL = localURL.URLByAppendingPathComponent(String(self.hashValue) + "." + ext)
            
            // Obtengo datos de Path local
            let data = NSData(contentsOfURL: localURL)
            
            // Intento desempaquetar. Si tiene datos devuelvo la imagen
            if let d : NSData = data {
                print("Existe en caché. Recuperando fichero de caché...")
                return d
            } else {

                // Cargo datos de remoto
                if let d = NSData(contentsOfURL: url){
                    print("Guardando datos en cache...")
                    // Guardo datos en caché
                    d.writeToURL(localURL, atomically: true)
                    // Devuelvo imagen
                    return d
                }
            }
        } catch {
            // Si hay algún error devuelvo nil (Sin datos)
            return nil
        }
        return nil // El compi me obliga... no le vale el catch? falta más I+D (Investigación + Desesperación)
    }

```

Como se puede ver he usado una función `tryLoadFromCache(url:)` para intentar recuperar el dato desde local y si no cargarlo desde internet y guardarlo en local (repito: es la misma estrategia para el PDF y la Portada)

Gestión de Favoritos
---------------------
Para la carga de favoritos he usado NSUserData y guardo com key:value la referencia al libro favorito.

He optado por guardar el hashValue del libro como key y el valor (false/true) como value.


```swift
// en Book.swift
// Propiedad computada favorite
//   Usa NSUserData para persistir la información
    var favorite: Bool {
        get {
            return getFavFromNSUserData(String(self.hashValue))
        }
        set(newValue) {
            // Guardo favorito en NSUserData para persistir
            setFavAtNSUserData(String(self.hashValue), value: newValue)
            
            // ....
        }
}
```


Cuando quitamos un favorito se borra de NSUserData así que en realidad el value nunca será false. Por ahora no me hace falta para más pero en el futuro podríamos guardar la isntancia del libro si queremos hacer más cosas ahí.

No he quedado 100% satisfecho con guardar directamente el Hash como key. Quizá debería haber guardado un key genérico ("favorites") y dentro un array de los libros que son favoritos. He pensado que el código sería más complejo y lo he dejado sencillo por ahora.



Notificación de cambio de Favorito para recargar tabla
--------------------------------------------------------
He optado por lanzar una notificación en el modelo de Book mediante la propiedad "favorite". 

1) Lo he implementado en su set y lanza una notificación a la que me subscribo en el LibraryTableViewController. 
2) En ese momento refresco el modelo, borro y recargo la lista de Favoritos con `refreshFavs()` en la clase Library 
3) Recargo el TableView mediante su método `reloadData()`


```swift
// en Book.swift
// Propiedad computada favorite
//   Usa NSUserData para persistir la información
    var favorite: Bool {
        // ....
        set(newValue) {
            //....

            // Notificar cambio de Favorito
            let nc = NSNotificationCenter.defaultCenter()
            let notif = NSNotification(name: BookDidChange, object: self, userInfo:["bookModelChange": self])
            nc.postNotification(notif)

        }
}

Notificar de selección de nuevo libro y salir del PDF en la vista detalle
-------------------------------------------------------------------------
El comportamiento que quería obtener cuando pulsaba un nuevo libro en el tableView estando visualizando un PDF no era cargar el PDF (similar a lo que hicimos con el wiki en el ejemplo StarWars del curso), si no que cargar la portada del libro seleccionado.

Nota: Este problema surje sobre todo en la disposición iPad de la aplicación, no en el iPhone

Me he basado en el patrón delegado y he creado un protocolo en LibraryViewControler

```swift
protocol LibraryViewControllerDelegate {
    func libraryViewController(viewCtrl: LibraryViewController, didSelectBook book:Book)
}
```

Este protocolo se implementa en BookViewController :

```swift
//MARK: - Delegate
func libraryViewController(viewCtrl: LibraryViewController, didSelectBook book: Book) {
    self.navigationController?.popViewControllerAnimated(true) 

    //Actualizar modelo
    self.model = book
    //Sincronizar vistas con nuevo modelo
    syncModelWithView()
}
```

Y al ser llamado realiza un `popViewController()` para quitar la vista detalle (el PDF) del navigation correspondiente.

Cambio de disposición de TableView para mostrar los datos ordenados por Tags o Secciones
------------------------------------------------------------------------------
Para ello he implementado un botón en el navigation bar. Este botón según lo pulsamos lanza una llamada a la función `change()`


```swift
// En viewDidLoad() de LibraryViewController
self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "ABC", style: UIBarButtonItemStyle.Plain, target: self, action: "change")
```

En change() compruebo el texto del botón, cambio el flag `tagView` a true/false y llamo a reload data. 

```swift
func change(){
    if self.navigationItem.rightBarButtonItem?.title == "ABC" {
        self.navigationItem.rightBarButtonItem?.title = "Tags"
        tagView = false
        self.tableView.reloadData()
    } else {
        self.navigationItem.rightBarButtonItem?.title = "ABC"
        tagView = true
        self.tableView.reloadData()
    }
}
```


En la carga de los datos en el TableView se tiene en cuenta el valor de tag view para cargar las secciones necesarias:

```swift
func bookAtIndexPath(indexPath: NSIndexPath) -> Book{
    var book: Book?
    if tagView {
        book = model.book(atIndex: indexPath.row, forTag: model.tagForIndex(indexPath.section))
    } else {
        book = model.book(atIndex: indexPath.row)
    }
    return book!
}
```

Ordenar por prioridad (si es favorito arriba y si no por )
---------------------------------------------------------
Una cosa que me ha dado algo de guerra es la ordenación según prioridad de los libros y tags en el TableView. Entendí desde el principio que había que implementar las extensiones Comparable para cada modelo, pero no sé si llego a comprender del todo bien la cosa:

Mi ejemplo del libro (el del tag es similar)


```swift

extension Book: Comparable { }
func <(lhs: Book, rhs: Book) -> Bool {
    if lhs.favorite == rhs.favorite {
        return  lhs.title < rhs.title
    } else if lhs.favorite == true {
        return true
    } else {
        return false
    }
}

```

- Si los dos son favoritos o no-favoritos comparo "normal" los libros por orden alfabético (por propiedad title)
- Si `lhs` es favorito, devuelvo ¿true? ¿Por qué? 
    - Entiendo que si estamos realizando una comparación "menor qué" debería devolver false ¿no?, o sea, la izquierda NO es menor que la derecha (el favorito es mayor que el no-favorito) Si embargo así no se comportaba como yo esperaba....algo entenderé mal. 

Otras consideraciones
---------------------

### Selectores. 

Los he tenido que llamar como strings en vez de con la nueva síntaxis `#selector()`. El problema es que yo tengo Swift 2.1 y esta síntaxis se implemento en 2.2. No he podido instalar Xcode 7.3 (creo que no me lo instala porque todavía tengo un Yosemite...No he podido instalar El Capitán porque es el equipo del curro, a ver si en verano puedo)


### Siguientes Pasos
Antes de subir a la App Store hay algunas cosas que quiero terminar:
- La carga de PDFs bloquea la aplicación
- El botón sandwitch en el splitViewControler de la interfaz de iPad...
- Una última refactorización de código
- Añadir tests: Si fuese una aplicacíon importante para mí no dudaría en implementarlos. Si acaba siendo un ejemplo no pasa nada, pero considero importante la mantenibilidad del código
- Modificar la interfaz usando AutoLayout. 
- Más funcionalidad:
    - Añadir etiquetas
    - Cargar más libros desde un backgr
