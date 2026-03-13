package sync;

import java.util.Map;

public abstract class BaseSyncService<T>{
    protected abstract String getEndPoint();
    protected abstract T mapToEntity(Map<String, Object> apiData);
    protected abstract void save(T entity);
}