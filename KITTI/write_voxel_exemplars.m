function write_voxel_exemplars

% load ids
object = load('kitti_ids_new.mat');
ids = object.ids_train;

% load data
object = load('data.mat');
data = object.data;
idx = data.idx_ap;

% cluster centers
centers = unique(idx);
centers(centers == -1) = [];
N = numel(centers);
fprintf('%d clusters\n', N);

% write the mapping from cluster center to azimuth and alpha
filename = 'Voxel_exemplars/mapping.txt';
fid = fopen(filename, 'w');
for i = 1:N
    azimuth = data.azimuth(centers(i));
    alpha = azimuth + 90;
    if alpha >= 360
        alpha = alpha - 360;
    end
    alpha = alpha*pi/180;
    if alpha > pi
        alpha = alpha - 2*pi;
    end
    fprintf(fid, '%d %f %f\n', i, azimuth, alpha);
end
fclose(fid);

% for each image
for i = 1:numel(ids)
    id = ids(i);
    filename = sprintf('Voxel_exemplars/%06d.txt', id);
    fid = fopen(filename, 'w');
    
    % write object info to file
    index = find(data.id == id);
    for j = 1:numel(index)
        ind = index(j);
        % cluste id
        cluster_idx = idx(ind);
        if cluster_idx ~= -1
            cluster_idx = find(centers == cluster_idx);
        end
        
        % flip
        is_flip = data.is_flip(ind);
        
        % bounding box
        bbox = data.bbox(:,ind);
        
        fprintf(fid, '%d %d %.2f %.2f %.2f %.2f\n', cluster_idx, is_flip, bbox(1), bbox(2), bbox(3), bbox(4));
    end
    
    fclose(fid);
    fprintf('%s: %d objects written\n', filename, numel(index));
end
