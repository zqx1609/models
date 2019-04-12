#! /bin/bash
export FLAGS_fraction_of_gpu_memory_to_use=0.95
export FLAGS_enable_parallel_graph=1
export FLAGS_sync_nccl_allreduce=1
export CUDA_VISIBLE_DEVICES=3
ERNIE_PRETRAIN=./Senta_models/ernie_pretrain_model/
DATA_PATH=./Senta_data
MODEL_SAVE_PATH=./save_models

# run_train
train() {
    python -u run_ernie_classifier.py \
        --use_cuda true \
        --verbose true \
        --do_train true \
        --do_val true \
        --do_infer false \
        --batch_size 16 \
        --init_checkpoint $ERNIE_PRETRAIN/params \
        --train_set $DATA_PATH/train.tsv \
        --dev_set $DATA_PATH/dev.tsv \
        --vocab_path $ERNIE_PRETRAIN/vocab.txt \
        --checkpoints $MODEL_SAVE_PATH \
        --save_steps 50 \
        --validation_steps 50 \
        --epoch 3 \
        --max_seq_len 128 \
        --ernie_config_path $ERNIE_PRETRAIN/ernie_config.json \
        --model_type "ernie_base" \
        --lr 2e-5 \
        --skip_steps 10 \
        --num_labels 2 \
        --random_seed 1
}

# run_eval
evaluate() {
    python -u run_ernie_classifier.py \
        --use_cuda true \
        --verbose true \
        --do_train false \
        --do_val true \
        --do_infer false \
        --batch_size 16 \
        --init_checkpoint ./save_models/step_1800/ \
        --dev_set $DATA_PATH/dev.tsv \
        --vocab_path $ERNIE_PRETRAIN/vocab.txt \
        --max_seq_len 128 \
        --ernie_config_path $ERNIE_PRETRAIN/ernie_config.json \
        --model_type "ernie_base" \
        --num_labels 2
}

# run_infer
infer() {
    python -u run_ernie_classifier.py \
        --use_cuda true \
        --verbose true \
        --do_train false \
        --do_val false \
        --do_infer true \
        --batch_size 16 \
        --init_checkpoint ./save_models/step_1800 \
        --test_set $DATA_PATH/test.tsv \
        --vocab_path $ERNIE_PRETRAIN/vocab.txt \
        --max_seq_len 128 \
        --ernie_config_path $ERNIE_PRETRAIN/ernie_config.json \
        --model_type "ernie_base" \
        --num_labels 2
}

main() {
    local cmd=${1:-help}
    case "${cmd}" in
        train)
            train "$@";
            ;;
        eval)
            evaluate "$@";
            ;;
        infer)
            infer "$@";
            ;;
        help)
            echo "Usage: ${BASH_SOURCE} {train|eval|infer}";
            return 0;
            ;;
        *)
            echo "Unsupport commend [${cmd}]";
            echo "Usage: ${BASH_SOURCE} {train|eval|infer}";
            return 1;
            ;;
    esac
}
main "$@"
