class Empleado{
	var rol
	var estamina
	var tareasRealizadas = []
	method rol(unRol){
		rol = unRol
	}
	method rol(){
		return rol
	}
	method realizar(tarea){
		if(not self.puedeRealizar(tarea)){
			throw new NoPuedeRealizarTareaError()
		}
		rol.realizarPor(self,tarea)
		tareasRealizadas.add(tarea.dificultadPara(self))
		/*Necesito una lista de las realizadas para guardar la dificultad al momento
		 de hacerlas, tambien se podria guardar directamente una lista con las dificultades.*/
	}
	method recuperarEstamina(puntos)
	method comer(fruta){
		self.recuperarEstamina(fruta.estaminaQueAporta())
	}
	method perderEstamina(puntos){
		var enCuantoQueda = estamina - puntos
		if (enCuantoQueda<0){
			throw new EstaminaPorDebajoDe0Error()
		}
		estamina = enCuantoQueda
	}
	method estaminaMayorA(puntos){
		return estamina > puntos
	}
	method tieneEstasHerramientas(listaHerramientas){
		return rol.tieneEstasHerramientas(listaHerramientas)
	}
	method perderMitadDeEstamina(){
		estamina = estamina/2
	}
	method puedeDefender(){
		return rol.puedeDefender()
	}
	method limpiar(estaminaAPerder){
		self.perderEstamina(rol.cuantoPierdoPorLimpiar(estaminaAPerder))
	}
	method defender(){
		return rol.defiende(self)
	}
	method esCiclope(){
		return false
	}
	method fuerza(){
		return estamina/2 + 2
	}
	method fuerzaMayorA(puntos){
		return self.fuerza() > puntos
	}
	method fuerzaPorRol(){
		return rol.fuerzaExtra()
	}
	method experiencia(){
		return tareasRealizadas.size() * tareasRealizadas.sum({tarea => tarea.dificultadTarea()})
	}
	
	// originalmente la responsabilidad de saber si se puede realizar una tarea
	// estaba en la tarea, pero como con el capataz es diferente, hay que delegar al rol
	method puedeRealizar(tarea){
		return rol.puedeRealizar(self,tarea)
	}
}

class Ciclope inherits Empleado{
	override method recuperarEstamina(puntos){
		estamina += puntos
	}
	override method esCiclope(){
		return true
	}
	override method fuerza(){
		return (super() + self.fuerzaPorRol())/2
	}
}

class Biclope inherits Empleado{
	override method recuperarEstamina(puntos){
		estamina = 10.min(estamina+puntos)
	}
}

//Roles
class Rol{
	method tieneEstasHerramientas(listaHerr){
		return listaHerr.isEmpty()
	}
	method puedeDefender(){
		return true
	}
	method cuantoPierdoPorLimpiar(estamina){
		return estamina
	}
	method defiende(empleado){
		empleado.perderMitadDeEstamina()
	}
	method fuerzaExtra(){
		return 0
	}
	method realizarPor(emp,tarea){
		tarea.realizarsePor(emp)
	}
	method puedeRealizar(empleado,tarea){
		return tarea.puedeRealizarla(empleado)
	}
}

class Soldado inherits Rol{
	var danio
	override method fuerzaExtra(){
		return danio
	}
	override method defiende(empleado){
		danio += 2
	}
}

class Obrero inherits Rol{
	var herramientas
	constructor(listaHerr){
		herramientas = listaHerr
	}
	override method tieneEstasHerramientas(listaHerramientas){
		return herramientas.all({herr => listaHerramientas.contains(herr)})
	}
}

class Mucama inherits Rol{
	override method puedeDefender(){ 
		return false
	}
	method cuantoPierdoPorLimpiar(estamina){
		return 0
	}
}

class Capataz inherits Rol{
	var empleadosACargo
	constructor(listaEmpleados){
		empleadosACargo = listaEmpleados
	}
	override method realizarPor(emp,tarea){
		if(not self.puedoDelegar()){
			emp.realizar(tarea)
		}else{
			self.empleadoMasExperimentado().realizar(tarea)
		}
		
	}
	
	method empleadosQuePuedenRealizar(tarea){
		return empleadosACargo.filter({empl => empl.puedeRealizar(tarea)}
	}
	
	method empleadoMasExperimentado() {
		return self.empleadosQuePuedenRealizar(tarea).max({empl => empl.experiencia()})
	}
	
	override method puedeRealizar(empleado,tarea){
		return self.puedoDelegar() or super()
	}
	
	method puedoDelegar(){
		return self.empleadosQuePuedenRealizar(tarea).isEmpty()
	}
}

//TAREAS

class ArreglarMaquina{
	var maquina
	var herramientasNecesarias = []
	constructor(unaMaqu,herramientasNec){
		maquina = unaMaqu
		herramientasNecesarias = herramientasNec
	}
	method dificultadPara(empleado){
		return maquina.complejidad()*2
	}
	method puedeRealizarla(empleado){
		return empleado.estaminaMayorA(maquina.complejidad()) && empleado.tieneEstasHerramientas(herramientasNecesarias)
	}
	method realizarsePor(empleado){
		empleado.perderEstamina(maquina.complejidad())
	}
}

class DefenderSector{
	var gradoAmenaza
	constructor(gradoAmen){
		gradoAmenaza = gradoAmen
	}
	method dificultadPara(empleado){
		if(empleado.esCiclope()){
			return gradoAmenaza*2
		}else{
			return gradoAmenaza
		}
	}
	method puedeRealizarla(empleado){
		return empleado.puedeDefender() && empleado.fuerzaMayorA(gradoAmenaza)
	}
	method realizarsePor(empleado){
		empleado.defender()
	}
}

class LimpiarSector{
	var sector
	var dificultadLimpieza = 10
	constructor(unSector){
		sector = unSector
	}
	method dificultadLimpieza(dificultad){
		dificultadLimpieza = dificultad
	}
	method estaminaRequerida(){
		if(sector.esGrande()){
			return 4
		}
		return 1
	}
	method dificultadPara(empleado){
		return dificultadLimpieza
	}
	method puedeRealizarla(empleado){
		return empleado.estaminaMayorA(self.estaminaRequerida())
	}
	method realizarsePor(empleado){
		empleado.limpiar(self.estaminaRequerida())
	}
}

//CLASES EXTRAS
class Maquina{
	var complejidad
	constructor(complejMaquina){
		complejidad = complejMaquina
	}
	method complejidad(){
		return complejidad
	}
}

class Sector{
	var tamanio
	constructor(tam){
		tamanio = tam
	}
	method esGrande(){
		return tam > 10
	}
}

object banana{
	method estaminaQueAporta(){
		return 10
	}
}

object manzana{
	method estaminaQueAporta(){
		return 5
	}
}

object uvas{
	method estaminaQueAporta(){
		return 1
	}
}

class NoPuedeRealizarTareaError inherits Exception{}
class EstaminaPorDebajoDe0Error inherits Exception{}
