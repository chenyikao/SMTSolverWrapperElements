/**
 * 
 */
package ompca;

import java.util.Map;

/**
 * @author Kao, Chen-yi
 *
 */
public interface Mappable<K, V> {

	Map<K, V> toMap();
	
}