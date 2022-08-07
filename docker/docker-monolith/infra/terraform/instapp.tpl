[docker-${envt}]
%{for i in range(length(instance_names_app_st)) ~}
${instance_names_app_st[i]}  ansible_host=${ips_app_st[i]}
%{ endfor ~}
