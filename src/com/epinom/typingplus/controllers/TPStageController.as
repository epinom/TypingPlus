﻿/**
* ...
* TPStageController
* Controla todo los elementos de la interfaz, especificamente el reposicionamiento de los elementos con redimensionamiento del browser
* 
* @author Ernesto Pino Martínez
* @version v07/12/2008 22:05
*/

package com.epinom.typingplus.controllers
{
	import com.epinom.typingplus.data.TPHashMap;
	import com.epinom.typingplus.models.TPDataModel;
	import com.epinom.typingplus.objects.TPInterfaceObject;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	public class TPStageController extends Sprite
	{
		/**
		 * @property
		 * Unica instancia de la clase, esta clase utiliza un patrom Singleton
		 */
		private static var _instance:TPStageController = null;
		
		/**
		 * @property
		 * Referencia al escenario de la pelicula principal
		 */
		private var _stage:Stage;
		
		/**
		 * @property
		 * Lista de objetos que se encuentran en pantalla
		 */
		private var _hashMap:TPHashMap;
		
		/**
		 * @property
		 * Valor minimo del ancho del escenario para el cual los objetos dejan de reposicionarse
		 */ 
		private var _minWidth:Number;	
		
		/**
		 * @property
		 * Valor minimo del alto del escenario para el cual los objetos dejan de reposicionarse
		 */ 
		private var _minHeight:Number;
		
		/**
		 * @property
		 * Valores constantes
		 */
		public static const STAGE_RESIZE:String = "onStageResize";
		
		/**
		 * @constructor
		 * Constructor de la clase
		 * 
		 * @param	singleton		Objeto de tipo Singleton, garantiza que la clase se intancie una unice vez		 
		 */
		function TPStageController(singleton:Singleton)
		{
			trace("TPStageController->TPStageController()");
			
			// Obteniendo referencia al escenario principal
			_stage = TPDataModel.getInstance().stage;
			
			// Inicializando propiedades
			_stage.align = StageAlign.TOP_LEFT;
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage.addEventListener(Event.RESIZE, onResizeHandler);
			_hashMap = new TPHashMap();			
		}
		
		/**
		 * @method
		 * Devuelve la unica instancia de la clase InterfaceManager
		 * 
		 * @return	instancia		Unica instancia de la clase TPStageController 	
		 */
		public static function getInstance():TPStageController
		{
			if (_instance == null)
				_instance = new TPStageController(new Singleton());
			return _instance;
		}
		
		/**
		 * Configura la resolucion minima para el redimencionamiento del browser
		 * 
		 * @param	minWidth		Ancho minimo de resolucion para el cual deja de redimencionarse la aplicacion
		 * @param	minHeight		Alto minimo de resolucion para el cual deja de redimencionarse la aplicacion
		 */
		public function config(minWidth:Number, minHeight:Number):void
		{
			_minWidth = minWidth;
			_minHeight = minHeight;
		}
		
		/**
		 * @method
		 * Visualiza la aplicacion a pantalla completa
		 * 
		 * @param	status		Estado de visualizacion de pantalla
		 */
		public function fullScreen(status:String):void
		{			
			_stage.displayState = status;
		}
		
		/**
		 * @method
		 * Adiciona un objeto al escenario
		 * 
		 * @param	idHash			Identificador del objeto en la tabla hash
		 * @param	object			Objeto a almacenar
		 * @param	visualObject	Indica si el objeto debe ser agregado a la lista de visualizacion
		 */
		public function addObject(idHash:String, object:*, visualObject:Boolean = true):void
		{		
			//trace("TPStageController->addObject()");		
			
			// Agrega un elemento a la tabla hash
			_hashMap.add(idHash, object);
			
			// Posicionando del objeto
			locateObject(object);	
			if (visualObject)
				_stage.addChild((object as TPInterfaceObject).interactiveObject);	
		}
		
		/**
		 * @method
		 * Elimina un objeto de la lista de visualizacion
		 * 
		 * @param	idHash		Identificador del objeto en la tabla hash
		 */
		public function removeObject(idHash:String, removeFromStage:Boolean = true):TPInterfaceObject
		{
			var io:TPInterfaceObject = getItemAt(idHash) as TPInterfaceObject;
			if(removeFromStage == true)
				_stage.removeChild(io.interactiveObject);
			_hashMap.remove(idHash);
			return io;			
		}
		
		/**
		 * @method
		 * Devuelve un elemento registrado en la tabla hash dado su identificador
		 * 
		 * @param	idHash		Cadena que identifica el elemento en la tabla hash
		 * @return	*			Objeto representado en el escenario
		 */
		public function getItemAt(idHash:String):*
		{
			// Devuelve el objeto asociado a dicha clave
			var object:TPInterfaceObject = _hashMap.getValue(idHash);
			return object;
		}
		
		/**
		 * @method
		 * Visualiza un objeto, lo agrega a la lista de visualizacion
		 * 
		 * @param	idHash		Identificador del objeto en la tabla hash		 
		 */
		public function visualizeObject(idHash:String):void
		{
			var object:* = _hashMap.getValue(idHash);
			_stage.addChild((object as TPInterfaceObject).interactiveObject);	
		}			
		
		/**
		 * @method
		 * Posiciona un objeto en el escenario
		 * 
		 * @param	object		Objeto que se posicionara en el escenario
		 */
		public function locateObject(object:*):void
		{
			//trace("TPStageController->locateObject()");
			
			// Conviertiendo el objeto generico en un TPInterfaceObject
			var object:TPInterfaceObject = object as TPInterfaceObject;				
			
			// Si el objeto no ha sido posicionado la primera vez
			if (!object.positionInitialized) 
			{
				// Actualizando inicializacion de posicionamiento
				object.positionInitialized = true;
				
				// Posiciono el objeto por primera vez
				object.interactiveObject.x = _stage.stageWidth * object.percentageX / 100;
				object.interactiveObject.y = _stage.stageHeight * object.percentageY / 100;
				
				// Si el padding es de forma porcentual
				if(object.percentagePadding)
				{
					// Aplicando paddings, si lo tiene definido
					if(object.paddingTop != -1)
						object.interactiveObject.y += object.paddingTop * object.interactiveObject.height / 100;
					
					if(object.paddingBottom != -1)
						object.interactiveObject.y -= object.paddingBottom * object.interactiveObject.height / 100;
					
					if(object.paddingLeft != -1)
						object.interactiveObject.x += object.paddingLeft * object.interactiveObject.width / 100;
					
					if(object.paddingRight != -1)
						object.interactiveObject.x -= object.paddingRight * object.interactiveObject.width / 100;
				}
				else
				{
					// Aplicando paddings, si lo tiene definido
					if(object.paddingTop != -1)
						object.interactiveObject.y += object.paddingTop;
					
					if(object.paddingBottom != -1)
						object.interactiveObject.y -= object.paddingBottom;
					
					if(object.paddingLeft != -1)
						object.interactiveObject.x += object.paddingLeft;
					
					if(object.paddingRight != -1)
						object.interactiveObject.x -= object.paddingRight;
				}
			}
			else
			{
				var xPosition:Number = -1;
				var yPosition:Number = -1;
				
				// Si el objeto tiene especificado que se le haga un cambio de posicion cuando ocurra un redimensionamiento del browser
				if (object.changePositionX)	
					xPosition = _stage.stageWidth * object.percentageX / 100;

				if (object.changePositionY)
					yPosition = _stage.stageHeight * object.percentageY / 100;
				
				// Si el padding es de forma porcentual
				if(object.percentagePadding)
				{
					// Aplicando paddings, si lo tiene definido
					if(object.paddingTop != -1)
						yPosition += object.paddingTop * object.interactiveObject.height / 100;
					
					if(object.paddingBottom != -1)
						yPosition -= object.paddingBottom * object.interactiveObject.height / 100;
					
					if(object.paddingLeft != -1)
						xPosition += object.paddingLeft * object.interactiveObject.width / 100;
					
					if(object.paddingRight != -1)
						xPosition -= object.paddingRight * object.interactiveObject.width / 100;
				}
				else
				{
					// Aplicando paddings, si lo tiene definido
					if(object.paddingTop != -1)
						yPosition += object.paddingTop;
					
					if(object.paddingBottom != -1)
						yPosition -= object.paddingBottom;
					
					if(object.paddingLeft != -1)
						xPosition += object.paddingLeft;
					
					if(object.paddingRight != -1)
						xPosition -= object.paddingRight;
				}
				
				// Asignando nueva posicion sal objeto
				object.interactiveObject.x = xPosition;
				object.interactiveObject.y = yPosition;
			}

			// Si el objeto tiene especificado que se le haga un cambio de tamaño cuando ocurra un redimensionamiento del browser
			if (object.changeSize)
			{
				object.interactiveObject.width = _stage.stageWidth * object.percentageWidth / 100;
				object.interactiveObject.height = _stage.stageHeight * object.percentageHeight / 100;
			}
			
			if (object.centralReference)
			{
				// Variables para el control del calculo
				var position:Number;
				var totalSeparation:Number;					
				var totalWidth:Number;
				
				// Variable para controlar el orden del objeto
				var order:int = object.totalElements - object.elementOrder + 1;
				
				// Si la cantidad de objetos a posicionar es PAR
				if (object.totalElements % 2 == 0)
				{									
					// Calculando posicionamiento
					totalSeparation = ((object.totalElements / 2 - order) * object.separation) + (object.separation / 2);
					totalWidth = ((object.totalElements / 2 - order) * object.interactiveObject.width) + (object.interactiveObject.width / 2);
					position = _stage.stageWidth / 2 + totalSeparation + totalWidth;											
				}
				else	// Si la cantidad de objetos a posicionar es IMPAR
				{
					for (var j:int = object.totalElements; j > 0 ; j--) 
					{
						// Calculando posicionamiento
						totalSeparation = (Math.floor(object.totalElements / 2) - (order - 1)) * object.separation;
						totalWidth = (Math.floor(object.totalElements / 2) - (order - 1)) * object.interactiveObject.width;
						position = _stage.stageWidth / 2 + totalSeparation + totalWidth;	
					}
				}
				
				// Posicionando objeto
				object.interactiveObject.x = position;
				object.interactiveObject.y = _stage.stageHeight * object.yPosition / 100; 			
			}
		}
		
		/**
		 * @event
		 * Se ejecuta cuando se redimensiona el escenario
		 * Ejecuta la funcion actionsForElements() de la clase HashMap, pasandole por parametro la funcion locateObject() de la clase TPStageController,
		 * lo que hace que se realicen las acciones establecidas en la funcion locateObject() para cada registro de la clase HashMap
		 * 
		 * @param	evt		Evento 
		 */
		private function onResizeHandler(evt:Event):void
		{
			trace("TPStageController->onResizeHandler()");		
			
			 // Comprobando dimensiones minimas
			if ((_minWidth != 0 && _minHeight != 0) && (_stage.stageWidth >= _minWidth || _stage.stageHeight >= _minHeight))
			{
				// Ejecuto acciones para cada registro de la clase HashMap
				_hashMap.actionsForElements(this.locateObject);
			}				
		}
	}
}

/**
 * @singleton
 */
class Singleton{}