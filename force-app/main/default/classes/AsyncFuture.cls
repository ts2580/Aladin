/**
 * Created by trsty on 24. 9. 3..
 */

public with sharing class AsyncFuture {

    @Future
    public static void imFuture(){
        System.debug('나는 퓨처에요');
    }

}